
import React from 'react';
import { requireNativeComponent } from 'react-native';

export default class RNTfClassify extends React.Component {
  onPredictionMade = callback => ({nativeEvent}) => {
    if (callback) {
      callback(nativeEvent);
    }
  }
  render() {
    return (
      <TfCamera 
      style={{flex: 1}}
      onPredictionMade={this.onPredictionMade(this.props.onPredictionMade)}
      predictionEnabled={this.props.predictionEnabled}
      />
    )
  }
};

const TfCamera = requireNativeComponent('RNTTfCamera', RNTfClassify)
