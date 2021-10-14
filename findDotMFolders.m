function dotmfolders = findDotMFolders(subdir, exclList)
dotmfolders = {};

if ~exist('subdir','var')
    subdir = pwd;
end
if ~exist('exclList','var')
    exclList = {};
end

if ~iscell(exclList)
    exclList = {exclList};
end

subdirFullpath = filesepStandard_startup(subdir,'full');

if ~ispathvalid_startup(subdirFullpath, 'dir')
    fprintf('Warning: folder %s doesn''t exist\n', subdirFullpath);
    return;
end

% If current subjdir is in the exclList then go back to curr dir and exit
if isExcluded(subdirFullpath, exclList)
    return;
end

dirs = dir([subdirFullpath, '*']);
if isempty(dirs)
    return;
end

if isdotmfolder(subdirFullpath)
    dotmfolders = {filesepStandard_startup(subdirFullpath, 'nameonly')};
end

for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue;
    end
    if dirs(ii).name(1) == '.'
        continue;
    end
    dotmfolders = [dotmfolders; findDotMFolders([subdirFullpath, dirs(ii).name], exclList)]; %#ok<AGROW>
end





% -------------------------------------------------------------------------
function b = isdotmfolder(folder)
b = false;
if ~ispathvalid_startup(folder, 'dir')
    return
end
if isempty(dir([folder,'/*.m']))
    % Exceptions to rule that 'dotm' folder must have at least one '.m' file: 
    % it is a an executable folder (i.e. '/bin')
    if ~isempty(strfind(folder, '/bin/')) %#ok<*STREMP>
        b = true;
        return
    end
    return;
end
b = true;




% -------------------------------------------------------------------------
function b = isExcluded(pname, exclList)
b = true;
if pname(end)=='/'
    pname(end) = '';
end
[~,f,e] = fileparts(pname);
for ii = 1:length(exclList)
    if strcmp(exclList{ii}, [f,e])
        return;
    end
end
b = false;



