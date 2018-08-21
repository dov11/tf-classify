
import React from 'react';
import { requireNativeComponent, NativeModules, View,
  ActivityIndicator,
  Text } from 'react-native';
import { requestPermissions } from './handlePermissions';

const CameraManager = NativeModules.TFCameraModule;

export default class RNTfClassify extends React.Component {
  constructor(props) {
    super(props)
    this._lastEvent = ''
    this._lastEventsTime= null
    this.state = {
      isAuthorized: false,
      isAuthorizationChecked: false,
    }
  }
  static defaultProps = {
    permissionDialogTitle: 'Camera Peremission',
    permissionDialogMessage: 'Would you like to allow this app to use Camera?',
    notAuthorizedView: (
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Text
          style={{
            textAlign: 'center',
            fontSize: 16,
          }}
        >
          Camera not authorized
        </Text>
      </View>
    ),
    pendingAuthorizationView: (
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <ActivityIndicator size="small" />
      </View>
    ),
  }
  componentDidMount() {
    requestPermissions(
      CameraManager,
      this.props.permissionDialogTitle,
      this.props.permissionDialogMessage,
    ).then(isAuthorized => this.setState({ isAuthorized, isAuthorizationChecked: true }));
    // this.setState({ isAuthorized, isAuthorizationChecked: true });
  }
  onPredictionMade = callback => ({nativeEvent}) => {
    const EventThrottleMs = 500;
    if (
      this._lastEvent &&
      this._lastEventsTime &&
      JSON.stringify(nativeEvent) === this._lastEvent &&
      new Date() - this._lastEventsTime < EventThrottleMs
    ) {
      return;
    }
    if (callback) {
      callback(nativeEvent);
    }
  }
  render() {
    const { isAuthorized, isAuthorizationChecked } = this.state;
    const { onPredictionMade, predictionEnabled, pendingAuthorizationView, notAuthorizedView, modelName  } = this.props;
    if (isAuthorized) {
      return (
        <TfCamera 
        style={{flex: 1}}
        onPredictionMade={this.onPredictionMade(onPredictionMade)}
        predictionEnabled={predictionEnabled}
        modelName={modelName}
        autoFocus={true}
        // labelsName={this.props.labels}
        // float={this.props.float}
        />
      )
    } else if (!isAuthorizationChecked) {
      return pendingAuthorizationView;
    } else {
      return notAuthorizedView;
    }
  }
};

const TfCamera = requireNativeComponent('TfCamera', RNTfClassify)
