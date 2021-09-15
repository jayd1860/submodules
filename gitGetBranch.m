function [name, cmds, errs, msgs] = gitGetBranch(repo)
name = '';
cmds = {};
errs = -1;
msgs = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');

ii = 1;
kk = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git branch'); ii = ii+1; kk = ii-1;

[errs, msgs] = exeShellCmds(cmds, false, false);

if all(errs==0)
    branches = str2cell_startup(msgs{kk});
    for jj = 1:length(branches)
        if branches{jj}(1)=='*'
            break;
        end
    end
    name = strtrim(deblank(branches{jj}(2:end)));
end

cd(currdir);

