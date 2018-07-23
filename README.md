
# react-native-tf-classify

## Getting started

`$ npm install react-native-tf-classify --save`

### Mostly automatic installation

`$ react-native link react-native-tf-classify`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-tf-classify` and add `RNTfClassify.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNTfClassify.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNTfClassifyPackage;` to the imports at the top of the file
  - Add `new RNTfClassifyPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-tf-classify'
  	project(':react-native-tf-classify').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-tf-classify/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-tf-classify')
  	```


## Usage
```javascript
import RNTfClassify from 'react-native-tf-classify';

// TODO: What to do with the module?
RNTfClassify;
```
  