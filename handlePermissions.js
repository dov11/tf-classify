import { PermissionsAndroid, Platform } from 'react-native';

export const requestPermissions = async (hasVideoAndAudio, CameraManager, permissionDialogTitle, permissionDialogMessage) => {
    if (Platform.OS === 'ios') {
        let check = hasVideoAndAudio
            ? CameraManager.checkDeviceAuthorizationStatus
            : CameraManager.checkVideoAuthorizationStatus;

        if (check) {
            const isAuthorized = await check();
            return isAuthorized;
        }
    } else if (Platform.OS === 'android') {
        const grantedCamera = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.CAMERA, {
            title: permissionDialogTitle,
            message: permissionDialogMessage,
          });
        // const grantedStorage = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE, {
        //     title: permissionDialogTitle,
        //     message: permissionDialogMessage,
        //   });
    
          // On devices before SDK version 23, the permissions are automatically granted if they appear in the manifest,
          // so check and request should always be true.
          // https://github.com/facebook/react-native-website/blob/master/docs/permissionsandroid.md
          const isAuthorized =
            Platform.Version >= 23 ? grantedCamera === PermissionsAndroid.RESULTS.GRANTED : grantedCamera === true;
            // Platform.Version >= 23 ? (grantedCamera === PermissionsAndroid.RESULTS.GRANTED && grantedStorage === PermissionsAndroid.RESULTS.GRANTED) : grantedCamera === true;
    
          return isAuthorized;
    }
    return true;
}