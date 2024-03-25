fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### clean

```sh
[bundle exec] fastlane clean
```

Deletes build directory

### test_cocoapods_pod

```sh
[bundle exec] fastlane test_cocoapods_pod
```

Runs the tests to verify a CocoaPod builds correctly; junit format test results will be in <base>/build/pod_test_results.xml

----


## iOS

### ios test_spm_package

```sh
[bundle exec] fastlane ios test_spm_package
```

Runs the unit tests for an iOS Swift Package Manager package; junit format test results will be in <base>/.build/build/spm_test_results.xml

----


## Mac

### mac test_spm_package

```sh
[bundle exec] fastlane mac test_spm_package
```

Runs the unit tests for a macOS Swift Package Manager package; junit format test results will be in <base>/.build/build/spm_test_results.xml

### mac build

```sh
[bundle exec] fastlane mac build
```



### mac notarize_app

```sh
[bundle exec] fastlane mac notarize_app
```

Notarizes Unified App

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
