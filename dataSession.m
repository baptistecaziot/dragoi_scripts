
%% open NEV file and extract data

classdef dataSession < handle
  
    %% properties
    
    % private constants
    properties (Access = private, Constant = true)
        eyeDataFormat = '%f\t';
        eyeEvent = 129;
        eyeFPS = 30;
    end
    
    % private variables
	properties (Access = private)
        NEVfile;
        AVIfile;
    end
    
    % public variables
	properties (SetAccess = protected)
        % settings variables
        velocityThreshold = 10;
        cleanBlinks = 1;
        cleanSaccades = 1;
        
        % processing stages
        calibrationProcessed = 0;
        velocityProcessed = 0;
        
        % data variables
        eyeT; eyeX; eyeY; eyeP;
        eyeXdot; eyeYdot; eyePdot;
    end
    

    %% public methods
	methods (Access = public)
		
        % constructor
		function [ obj ] = dataSession(dataPath, NEVfile, AVIfile)
           
            % set file names
            obj.NEVfile = fullfile(dataPath,NEVfile);
			obj.AVIfile = fullfile(dataPath,AVIfile);
            
            % open data files
            try 
                
            catch exception
                error('Failed to open files with exception:\n%s',exception.message)
                
            end
                
        end
        
		% destructor
		function [] = delete(obj)
			try
                clearvars obj;
                
            catch exception
                error('Failed to close files properly with exception:\n%s',exception.message)
			end
        end
        
        % unpack eye position
		function setVar(obj,varargin)
            if ~mod(nargin,2)
                error('Incorrect number of arguments when setting properties');
            end
            for aa=1:nargin/2
                if ~isprop(obj,varargin{aa*2-1})
                    error('Unknown property');
                else
                   obj.(varargin{aa*2-1}) = varargin{aa*2};
                end
            end
        end
        
		% unpack eye position
		function unpackEye(obj)
            load(obj.NEVfile,'NEV');
            tmp = char(NEV.Data.SerialDigitalIO.UnparsedData);
            tmp = sscanf(tmp,obj.eyeDataFormat);
            tmp = reshape(tmp,6,size(tmp,1)/6)';
            obj.eyeT = tmp(:,4)*60 + tmp(:,5) + tmp(:,6)/obj.eyeFPS;
            obj.eyeX = tmp(:,1); obj.eyeY = tmp(:,2); obj.eyeP = tmp(:,3);
            clearvars NEV
        end
        
        % compute eye velocity
		function processVelocity(obj)
            obj.eyeXdot = [0; (obj.eyeX(2:end)-obj.eyeX(1:end-1)) ./ (obj.eyeT(2:end)-obj.eyeT(1:end-1))];
            obj.eyeYdot = [0; (obj.eyeY(2:end)-obj.eyeY(1:end-1)) ./ (obj.eyeT(2:end)-obj.eyeT(1:end-1))];
            obj.eyePdot = [0; (obj.eyeP(2:end)-obj.eyeP(1:end-1)) ./ (obj.eyeT(2:end)-obj.eyeT(1:end-1))];
        end
        
        % remove blinks and saccades
		function cleanEye(obj)
            if obj.cleanBlinks
                blinks = (obj.eyeX==0)|(obj.eyeY==0)|(obj.eyeP==0);
            else
                blinks = zeros(size(obj.eyeX));
            end
            if obj.cleanBlinks
                saccades = (obj.eyeXdot.^2 + obj.eyeYdot.^2) > obj.velocityThreshold.^2;
            else
                saccades = zeros(size(obj.eyeX));
            end
            toClean = blinks|saccades;
            obj.eyeT(toClean) = NaN; obj.eyeX(toClean) = NaN;
            obj.eyeY(toClean) = NaN; obj.eyeP(toClean) = NaN;
        end
        
        % unpack scene video
		function unpackScene(obj)
            vreader = VideoReader(obj.AVIfile);
            ff = 0;
            while hasFrame(vreader)
                ff = ff+1;
                video(:,:,:,ff) = readFrame(vreader);
            end
            close(vreader);
        end
        
    end
    
    
    %% private methods
    methods (Access = private)
        
    end
    
end
