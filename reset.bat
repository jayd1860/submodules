rmdir $1 /s /q
git clone $2
cd $1
git checkout development
git submodule update --init
