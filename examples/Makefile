%:
	cd .. && make $@

install:
	sh scripts/prebuilt_macros.sh unzip
	bundle exec pod install --verbose

spm.fetch:
	bundle exec pod spm macro fetch --all --verbose

spm.prebuild:
	bundle exec pod spm macro prebuild --all --verbose

build:
	sh scripts/xcodebuild.sh

test:
	env XCODEBUILD_ACTION=test sh scripts/xcodebuild.sh
