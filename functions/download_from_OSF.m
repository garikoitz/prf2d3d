function download_from_OSF(image_path)
% download_from_OSF Download files from OSF
    % Try to download it from osf.io
    projectID = 'gwsj7';
    folderName = 'prf2d3d_DATA_mats';
    folderID = '64f05c366d1e89043915160f';
    
    [p,f,e] = fileparts(image_path);
    fname = [f e];

    apiURL = ['https://api.osf.io/v2/nodes/' projectID...
              '/files/osfstorage/' folderID '/?filter[name]=' fname];
                     
    R = webread(apiURL);
    if ~isempty(R.data)
        system(['wget https://osf.io/' R.data.attributes.guid '/download -O '...
                image_path])
    else
        error(['The file ' fname ' does not exist locally or in osf.io. ' ...
               'Make the stimulus and upload it to osf.io'])

    end

end