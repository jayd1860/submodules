function [cmds, errs, msgs] = gitSetBranch(repo, branch, preview, quiet)
cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('branch','var') || isempty(branch)
    branch = 'development';
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('quiet','var') || isempty(quiet)
    quiet = 1;
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git checkout %s', branch); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview, quiet);

cd(currdir);

