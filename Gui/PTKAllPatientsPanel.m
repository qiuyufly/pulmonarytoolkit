classdef PTKAllPatientsPanel < PTKCompositePanel
    % PTKAllPatientsPanel.  Part of the gui for the Pulmonary Toolkit.
    %
    %     This class is used internally within the Pulmonary Toolkit to help
    %     build the user interface.
    %
    %     PTKAllPatientsPanel represents the panel in the Patient Browser
    %     showing all datasets grouped by patient.
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2013.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties (Access = private)
        PatientPanels
        PatientPanelsMap
        PatientDatabase
        GuiCallback
    end
    
    methods
        function obj = PTKAllPatientsPanel(parent, patient_database, gui_callback, reporting)
            obj = obj@PTKCompositePanel(parent, reporting);
            obj.PatientDatabase = patient_database;
            obj.GuiCallback = gui_callback;
            
            obj.PatientPanels = containers.Map;
            obj.PatientPanelsMap = containers.Map;
            
            obj.AddPatientPanels;
        end

        function DatabaseHasChanged(obj)
            obj.RemoveAllPanels;
            obj.PatientPanels = containers.Map;
            obj.PatientPanelsMap = containers.Map;
            obj.AddPatientPanels;
        end
        
        % This determines the y-coordinate (relative to the top of the patient
        % details panel) of the top and bottom of the patient panel
        function [y_min, y_max] = GetYPositionsForPatientId(obj, patient_id)
            if ~obj.PatientPanelsMap.isKey(patient_id)
                y_min = [];
                y_max = [];
                return;
            end
            
            panel = obj.PatientPanelsMap(patient_id);
            
            y_min = panel.CachedMinY;
            y_max = panel.CachedMaxY;
        end

        function SelectSeries(obj, patient_id, series_uid, selected)
            if obj.PatientPanelsMap.isKey(patient_id)
                panel = obj.PatientPanelsMap(patient_id);
                panel.SelectSeries(series_uid, selected);
            else
                obj.Reporting.ShowWarning('PTKAllPatientsSlidingPanel.PatientNotFound', 'A patient was selected but the corresponding patient panel was not found', []);
            end
        end
        
        function DeletePatient(obj, patient_id)
            if obj.PatientPanelsMap.isKey(patient_id)
                panel = obj.PatientPanelsMap(patient_id);
                panel.DeletePatient;
            else
                obj.Reporting.ShowWarning('PTKAllPatientsSlidingPanel.PatientNotFound', 'A patient was selected but the corresponding patient panel was not found', []);
            end
        end
        
        
    end
    
    methods (Access = private)
                
        function AddPatientPanels(obj)
            % The Patient Database will merge together patients with same name if this is specified by the settings
            patient_info_list = obj.PatientDatabase.GetPatients;
            
            for patient_detail = patient_info_list
                obj.AddPatientPanel(PTKPatientPanel(obj, patient_detail{1}, obj.GuiCallback, obj.Reporting));
            end
        end
        
        function AddPatientPanel(obj, panel)
            obj.PatientPanels(panel.Id) = panel;
            for id = panel.AllIds
                obj.PatientPanelsMap(id{1}) = panel;
            end
            obj.AddPanel(panel);
        end
        
    end
end
