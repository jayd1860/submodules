function [cmds, errs, msgs] = downloadSharedLibs(options)
cmds = {};
errs = 0;
msgs = {};

if ~exist('options','var') || (isnumeric(options) && options==0)
    options = 'init';
end

s = parseGitSubmodulesFile();

% Check for missing libs
kk = checkMissingLibraries(s);
if isempty(kk) && optionExists_startup(options, 'init')
    return;
end

if optionExists_startup(options, 'init')
    [cmds, errs, msgs] = gitSubmodulesInit();
elseif optionExists_startup(options, 'update')
    [cmds, errs, msgs] = gitSubmodulesUpdate();
end

% Check again for missing libs
kk = checkMissingLibraries(s);
if isempty(kk) && (optionExists_startup(options, 'init') || all(errs==0))
    return;
end

% Try to install missing libs without git
branch = warningGitFailedToInstall(s(kk,:));
if ~isempty(branch)
    if optionExists_startup(options, 'init')
        downloadSubmodulesWithoutGit(s(kk,:), branch);
    elseif optionExists_startup(options, 'update')
        updateSubmodulesWithoutGit(s, branch);
    end
end

% Check again for missing libs
kk = checkMissingLibraries(s);
if isempty(kk)
    errs = 0;
    return;
end

q = warningManualInstallRequired(s(kk,:));
if q==1
    errs = -2;
else
    paths = searchFiles();
    if isempty(paths)
        errs = -1;
    end
end



% ----------------------------------------------------------
function kk = checkMissingLibraries(s)
kk = [];
for ii = 1:size(s,1)
    if isIncompleteSubmodule(s{ii,3})
        removeFolderContents(s{ii,3});
        kk = [kk, ii]; %#ok<AGROW>
    else
        addSearchPaths(s(ii,:));
    end
end


% ----------------------------------------------------------
function branch = warningGitFailedToInstall(s)
ii = 1;
msg{ii} = sprintf('WARNING: Git failed to install the following libraries required by this application:\n\n'); ii = ii+1;
for jj = 1:size(s,1)
    msg{ii} = sprintf('    %s\n', s{jj,1}); ii = ii+1;
end
msg{ii} = sprintf('\n'); ii = ii+1; %#ok<SPRINTFN>
msg{ii} = sprintf('Git might not be installed on your computer. '); ii = ii+1;
msg{ii} = sprintf('These libraries can still be installed without git. Please provide a branch name (default: ''development'') '); ii = ii+1;
msg{ii} = sprintf('of the submodles branches to download that matches the branch of the parent repo (this application).');
msg = [msg{:}];

branch = inputdlg(msg, 'MISSING LIBRARIES', 1);
if ~isempty(branch)
    branch = branch{1};
end



% ----------------------------------------------------------
function q = warningManualInstallRequired(s)
ii = 1;
msg{ii} = sprintf('WARNING: The following libraries required by this application are still missing:\n\n'); ii = ii+1;
for jj = 1:size(s,1)
    msg{ii} = sprintf('    %s\n', s{jj,1}); ii = ii+1;
end
msg{ii} = sprintf('\n'); ii = ii+1;
msg{ii} = sprintf('Either a) install git and rerun setpaths or b) download the submodules manually and provide their locations. '); ii = ii+1;
msg{ii} = sprintf('Select option:');
msg = [msg{:}];

q = menu(msg, {'Quit setpaths, install git and rerun setpaths','Download submodules manually and provide their locations'});




% ----------------------------------------------------------
function addSearchPaths(s)
kk = [];
exclSearchList  = {'.git'};
for ii = 1:size(s,1)
    foo = findDotMFolders(s{ii,3}, exclSearchList);
    for kk = 1:length(foo)
        addpath(foo{kk}, '-end');
        setpermissions(foo{kk});
    end
end




% ---------------------------------------------------
function setpermissions(appPath)
if isunix() || ismac()
    if ~isempty(strfind(appPath, '/bin'))
        fprintf(sprintf('chmod 755 %s/*\n', appPath));
        files = dir([appPath, '/*']);
        if ~isempty(files)
            system(sprintf('chmod 755 %s/*', appPath));
        end
    end
end


