
import React from 'react';
import { requireNativeComponent } from 'react-native';

export default class RNTfClassify extends React.Component {
  render() {
    return (
      <TfCamera style={{flex: 1}}/>
    )
  }
};

const TfCamera = requireNativeComponent('RNTTfCamera', RNTfClassify)
