function [cmds, errs, msgs] = gitSubmodulesUpdate(repo, preview)
cmds = {};
errs = -1;
msgs = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');

ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git submodule update --init'); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

cd(currdir);

