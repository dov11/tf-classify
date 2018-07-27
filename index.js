
import React from 'react';
import { NativeModules, requireNativeComponent } from 'react-native';

const { RNTfClassify } = NativeModules;

export default class RNTfClassify extends React.Component {
  render() {
    return (
      <TfCamera />
    )
  }
};

const TfCamera = requireNativeComponent('TfCamera', RNTfClassify)
