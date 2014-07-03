classdef processedLabData < labData
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    %%
    properties %(SetAccess= private)  Cannot set to private, because labData will try to set it when using split()
        gaitEvents %labTS
        procEMGData %processedEMGTS
        angleData %labTS (angles based off kinematics)
        adaptParams %labTS (parameters whcih characterize adaptation process)
    end
    
    properties (Dependent)        
%         tempParams
%         spatialParams
        isSingleStride
    end
    
    %%
    methods
        
        %Constructor:
        function this=processedLabData(metaData,markerData,EMGData,GRFData,beltSpeedSetData,beltSpeedReadData,accData,EEGData,footSwitches,events,procEMG,angleData) %All arguments are mandatory
            if nargin<12 %metaData does not get replaced!
               markerData=[];
               EMGData=[];
               GRFData=[];
               beltSpeedSetData=[];
               beltSpeedReadData=[];
               accData=[];
               EEGData=[];
               footSwitches=[];
               events=[];
               procEMG=[];
               angleData = [];
            end
            this@labData(metaData,markerData,EMGData,GRFData,beltSpeedSetData,beltSpeedReadData,accData,EEGData,footSwitches);
            if isa(events,'labTimeSeries') || isempty(events)
                this.gaitEvents=events;
            else
                ME=MException('processedLabData:Constructor','events parameter is not a labTimeSeries object.');
                throw(ME);
            end
            if isa(procEMG,'processedEMGTimeSeries') || isempty(procEMG)
                this.procEMGData=procEMG;
            else
                ME=MException('processedLabData:Constructor','procEMG parameter is not a processedEMGTimeSeries object.');
                throw(ME);
            end
            if isa(angleData,'labTimeSeries') || isempty(angleData)
                this.angleData=angleData;
            else             
                ME=MException('processedLabData:Constructor','angleData parameter is not a labTimeSeries object.');
                throw(ME);
            end             
        end
       
        %Access method for fields not defined in raw class.
        function partialProcEMGData=getProcEMGData(this,muscleName)
            partialProcEMGData=this.getPartialData('procEMGData',muscleName);
        end
        
        function list=getProcEMGList(this)
            list=this.getLabelList('procEMGData');
        end
        
        function partialGaitEvents=getPartialGaitEvents(this,eventName)
            partialGaitEvents=this.getPartialData('gaitEvents',eventName);
        end
        
        function list=getEventList(this)
            list=this.getLabelList('gaitEvents');
        end
        
        function partialAngleData= getAngleData(this,angleName)
            partialAngleData=this.getPartialData('angleData',angleName);
        end
        
        function partialParamData=getParam(this,paramName)
            partialParamData=this.getPartialData('adaptParams',paramName);
        end
                
%         function adaptParams=calcAdaptParams(this)
%             adaptParams=calcParameters(this);            
%         end
           
%         %Getters for dependent properties:
%         function tParams=get.tempParams(this)
%             tParams=temporalParameters(this);
%         end
%         
%         function sParams=get.spatialParams(this)
%             sParams=spatialParameters(this.gaitEvents,this.markerData);
%         end
        
        function b=get.isSingleStride(this)
           b=isa(this,'strideData'); 
        end
        
        %Separate into strides!
        function steppedDataArray=separateIntoStrides(this,triggerEvent)
            %triggerEvent needs to be one of the valid gaitEvent labels
            
            %Determine end event (ex: if triggerEvent='LHS' then we
            %need 'RTO')           
            if strcmpi(triggerEvent(2:3),'HS')
                eventType = 'TO';
            else
                eventType = 'HS';
            end
            if strcmpi(triggerEvent(1),'R')
                opLeg = 'L';
            else
                opLeg = 'R';
            end
            refLegEventList=this.getPartialGaitEvents(triggerEvent);
            opLegEventList=this.getPartialGaitEvents([opLeg,eventType]);
            refIdxLst=find(refLegEventList==1);
            opIdxLst=find(opLegEventList==1);
            auxTime=this.gaitEvents.Time;
            steppedDataArray={};
            for i=1:length(refIdxLst)-2
                steppedDataArray{i}=this.split(auxTime(refIdxLst(i)),auxTime(opIdxLst(find(opIdxLst(:)>refIdxLst(i+1),1,'first'))),'strideData');
            end
        end
        %Development version: get strides as a 2.5 continuous strides
%         function steppedDataArray=separateIntoStrides(this,triggerEvent)
%             %triggerEvent needs to be one of the valid gaitEvent labels
%             triggerEventList=this.getPartialGaitEvents(triggerEvent);
%             if strcmpi(triggerEvent(1),'L')
%                 contraEvent=['R' triggerEvent(2:end)];
%             else
%                 contraEvent=['L' triggerEvent(2:end)];
%             end
%             contraEventList=this.getPartialGaitEvents(contraEvent);
%             idxLst=find(triggerEventList==1);
%             contraLst=find(contraEventList==1);
%             auxTime=this.gaitEvents.Time;
%             steppedDataArray={};
%             for i=1:length(idxLst)-1
%                 idxFollowingContraEvent=contraLst(contraLst>idxLst(i+1));
%                 if ~isempty(idxFollowingContraEvent)
%                     steppedDataArray{i}=this.split(auxTime(idxLst(i)),auxTime(idxFollowingContraEvent(1)),'strideData');
%                 end
%             end
%         end
        
    end
    
    
end
