function build()
    % ndi.docs.build - build the NDI markdown documentation from Matlab source
    %
    % Builds the NDI documentation locally in $NDI-matlab/docs and updates the mkdocs-yml file
    % in the $NDI-matlab directory.
    %
    % **Example**:
    %   ndi.docs.build();
    %
    % Need to move mkdocs.yml to the root directory of the repo before running `mkdocs gh-deploy`
    % on regular command line (not Matlab command line).
    %

    disp('Writing NDI document documentation...');

    ndi.docs.all_documents2markdown();

    % make sure we don't traverse the the 'site' directory
    ndi_path = fileparts(fileparts(ndi.common.PathConstants.RootFolder));

    site_directory = fullfile(ndi_path, 'site');
    mkdirIfNotExist(site_directory)
    vlt.file.touch(fullfile(site_directory, '.matlab2markdown-ignore'));

    ndi_docs_directory = fullfile(ndi_path, 'docs', 'NDI-matlab');
    reference_directory = fullfile(ndi_docs_directory, 'reference'); % code reference path
    ymlpath = fullfile('NDI-matlab', 'reference');

    disp('Now writing function reference...');

    disp('Writing documents pass 1');

    source_directory = fullfile(ndi_path, 'src', 'ndi');

    out1 = vlt.docs.matlab2markdown(source_directory,reference_directory,ymlpath,[],'','https://vh-lab.github.io/NDI-matlab/');
    os = vlt.docs.markdownoutput2objectstruct(out1); % get object structures

    save([ndi_path filesep 'docs' filesep 'documentation_structure.mat'],'os','-mat');

    disp('Writing documents pass 2, with all links');
    out2 = vlt.docs.matlab2markdown(source_directory,reference_directory,ymlpath, os,'','https://vh-lab.github.io/NDI-matlab/');

    spaces = 6; % used to be 4 when only 1 set of tools
    T = vlt.docs.mkdocsnavtext(out2,spaces);

    ymlfile.references = fullfile(ndi_docs_directory, 'mkdocs-references.yml');
    ymlfile.start = fullfile(ndi_docs_directory, 'mkdocs-start.yml');
    ymlfile.end = fullfile(ndi_docs_directory, 'mkdocs-end.yml');
    ymlfile.documents = fullfile(ndi_docs_directory, 'documents', 'documents.yml');
    ymlfile.main = fullfile(ndi_docs_directory, 'mkdocs.yml');

    vlt.file.str2text(ymlfile.references,T);

    T0 = vlt.file.text2cellstr(ymlfile.start);
    T1 = vlt.file.text2cellstr(ymlfile.documents);
    T1_1 = {'    - Code reference:'};
    T2 = vlt.file.text2cellstr(ymlfile.references);
    T3 = vlt.file.text2cellstr(ymlfile.end);

    Tnew = cat(2,T0,T1,T1_1,T2,T3);

    vlt.file.cellstr2text(ymlfile.main,Tnew);
end

function mkdirIfNotExist(folderPath)
    if ~isfolder(folderPath)
        mkdir(folderPath);
    end
end
