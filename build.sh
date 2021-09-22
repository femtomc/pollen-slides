cd pollen
raco pollen reset
rm css/*.css
rm -rf images
rm -rf latex
raco pollen render -r .
raco pollen publish . $(pwd)/../example
raco pollen reset
cd ..
msg="Rebuilding example - $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi
cd docs
cp -r ../example/* .
cd ..
rm -rf example
git add .
git commit -m "$msg"
git push origin main
