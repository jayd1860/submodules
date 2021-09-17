function [cmds, errs, msgs] = gitRepoInit(repoLocal, url)
cmds = {};
errs = [];
msgs = {};

[~, repoName] = fileparts(repoLocal);

if isempty(repoLocal)
    repoLocal = pwd;
end
if isempty(url)
    repoRemote = '';
end
repoLocal = filesepStandard(repoLocal);
currdir = pwd;
cd(repoLocal)

if ispathvalid('./.git')
    rmdir('./.git','s')
end
if ispathvalid('./temp')
    rmdir('./temp','s')
end

% Try to init bare repo
ii = 1;
cmds1{ii,1} = sprintf('git init'); ii = ii+1;
cmds1{ii,1} = sprintf('git add .'); ii = ii+1;
cmds1{ii,1} = sprintf('git commit -m "First commit for standalone code"');
[errs1, msgs1] = exeShellCmds(cmds1);

% Check remote repo if it is bare
if ~ispathvalid('./temp')
    mkdir('./temp')    
end
cd('./temp');
cmd = sprintf('git clone %s', url);
[e, m] = system(cmd); %#ok<ASGLU>
if ~ispathvalid(['./', repoName, '/.git'])
    cd(repoLocal);
    errs = -1;
    return;
end

cd(repoLocal);

ii = 1;
cmds2{ii,1} = sprintf('git remote add origin %s', url); ii = ii+1;
cmds2{ii,1} = sprintf('git push -u origin master'); ii = ii+1;
[errs2, msgs2] = exeShellCmds(cmds2);

cmds = [cmds1; cmds2];
errs = [errs1(:)', errs2(:)'];
msgs = [msgs1; msgs2];


