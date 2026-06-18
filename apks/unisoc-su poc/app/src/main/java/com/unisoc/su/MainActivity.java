package com.unisoc.su;

/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Dipendenze richieste in app/build.gradle:
 *
 *   repositories { maven { url 'https://jitpack.io' } }
 *
 *   dependencies {
 *       implementation 'com.github.jackpal:Android-Terminal-Emulator:v1.0.70'
 *   }
 */

import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Environment;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import jackpal.androidterm.emulatorview.ColorScheme;
import jackpal.androidterm.emulatorview.EmulatorView;
import jackpal.androidterm.emulatorview.TermSession;
//

import java.io.IOException;
import java.io.File;
import java.io.InputStream;
import java.io.FileOutputStream;

public class MainActivity extends AppCompatActivity {

    // ── Comandi iniziali a scelta ────────────────────────────────────────────
    private static final String CMD_A_LABEL = "Get a system shell";
    private static final String CMD_A       = "sh rev.sh";

    private static final String CMD_B_LABEL = "Start ghostroot";
    private static final String CMD_B       = "source ghostroot";

    private static final String CMD_C_LABEL = "help";
    private static final String CMD_C       = "sh help";
    // ────────────────────────────────────────────────────────────────────────

    private static final int COLOR_BG     = 0xFF0D1117;
    private static final int COLOR_SYSTEM = 0xFF3FB950;
    private static final int COLOR_PROMPT = 0xFF58A6FF;
    private static final int COLOR_CMD    = 0xFFE6EDF3;

    private LinearLayout  mRoot;
    private LinearLayout  mChoiceBar;
    private LinearLayout  mTerminalContainer;
    private LinearLayout  mInputRow;
    private EditText      mInputView;
    private EmulatorView  mEmulatorView;
    private TermSession   mSession;
    private Process       mProcess;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        buildUi();
        ensureFiles();
        requestAllFilesAccess();
    }

    private boolean initialized = false;

    private void ensureFiles() {
        if (initialized) return;
        initialized = true;

        File dir = getFilesDir();
        if (!dir.exists()) dir.mkdirs();

    copyAssetToFiles("ghostroot");
    copyAssetToFiles("rev.sh");
    copyAssetToFiles("help");
    }

    private void requestAllFilesAccess() {
        if (!Environment.isExternalStorageManager()) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
            intent.setData(Uri.parse("package:" + getPackageName()));
            startActivity(intent);
        }
    }

    private void copyAssetToFiles(String filename) {
        File outFile = new File(getFilesDir(), filename);
        if (outFile.exists()) return;

        try (InputStream is = getAssets().open(filename);
             FileOutputStream os = new FileOutputStream(outFile)) {

            byte[] buffer = new byte[4096];
            int read;
            while ((read = is.read(buffer)) != -1) {
                os.write(buffer, 0, read);
            }
            os.flush();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void buildUi() {
        mRoot = new LinearLayout(this);
        mRoot.setOrientation(LinearLayout.VERTICAL);
        mRoot.setBackgroundColor(COLOR_BG);

        // ── Title row: now includes a toggle button so you can bring the
        //    command bar back at any time without restarting the app ──────
        LinearLayout titleRow = new LinearLayout(this);
        titleRow.setOrientation(LinearLayout.HORIZONTAL);
        titleRow.setBackgroundColor(0xFF161B22);
        titleRow.setPadding(16, 8, 16, 8);

        TextView titleBar = new TextView(this);
        titleBar.setText("  \u25b6  Terminal");
        titleBar.setTextSize(13f);
        titleBar.setTypeface(Typeface.MONOSPACE);
        titleBar.setTextColor(COLOR_SYSTEM);
        titleBar.setLayoutParams(new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f));

        Button toggleCommandsBtn = new Button(this);
        toggleCommandsBtn.setText("\u2261 Commands");
        toggleCommandsBtn.setTypeface(Typeface.MONOSPACE);
        toggleCommandsBtn.setTextSize(10f);
        toggleCommandsBtn.setTextColor(COLOR_PROMPT);
        toggleCommandsBtn.setBackgroundColor(0xFF21262D);
        toggleCommandsBtn.setOnClickListener(v -> {
            boolean visible = mChoiceBar.getVisibility() == View.VISIBLE;
            mChoiceBar.setVisibility(visible ? View.GONE : View.VISIBLE);
        });

        titleRow.addView(titleBar);
        titleRow.addView(toggleCommandsBtn);

        mChoiceBar = new LinearLayout(this);
        mChoiceBar.setOrientation(LinearLayout.HORIZONTAL);
        mChoiceBar.setBackgroundColor(0xFF161B22);
        mChoiceBar.setPadding(12, 10, 12, 10);

        TextView choiceLabel = new TextView(this);
        choiceLabel.setText("Run with:  ");
        choiceLabel.setTypeface(Typeface.MONOSPACE);
        choiceLabel.setTextSize(12f);
        choiceLabel.setTextColor(0xFF8B949E);

        Button btnA = makeChoiceButton(CMD_A_LABEL, 0xFF388BFD);
        Button btnB = makeChoiceButton(CMD_B_LABEL, 0xFF3FB950);
        Button btnC = makeChoiceButton(CMD_C_LABEL, 0xFFFF1100);
        mChoiceBar.addView(choiceLabel);
        mChoiceBar.addView(btnA);
        mChoiceBar.addView(btnB);
        mChoiceBar.addView(btnC);

        mTerminalContainer = new LinearLayout(this);
        mTerminalContainer.setOrientation(LinearLayout.VERTICAL);
        mTerminalContainer.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f));

        mInputRow = new LinearLayout(this);
        mInputRow.setOrientation(LinearLayout.HORIZONTAL);
        mInputRow.setPadding(8, 4, 8, 4);
        mInputRow.setBackgroundColor(COLOR_BG);

        TextView prompt = new TextView(this);
        prompt.setText("$ ");
        prompt.setTypeface(Typeface.MONOSPACE);
        prompt.setTextSize(14f);
        prompt.setTextColor(COLOR_PROMPT);

        mInputView = new EditText(this);
        mInputView.setTypeface(Typeface.MONOSPACE);
        mInputView.setTextSize(13f);
        mInputView.setTextColor(COLOR_CMD);
        mInputView.setHintTextColor(0xFF484F58);
        mInputView.setHint("Insert a command...\u2026");
        mInputView.setBackground(null);
        mInputView.setImeOptions(EditorInfo.IME_ACTION_SEND);
        mInputView.setSingleLine(true);
        mInputView.setEnabled(false);
        mInputView.setLayoutParams(new LinearLayout.LayoutParams(
                0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f));

        Button sendBtn = new Button(this);
        sendBtn.setText("\u21b5");
        sendBtn.setTypeface(Typeface.MONOSPACE);
        sendBtn.setTextSize(14f);
        sendBtn.setTextColor(COLOR_SYSTEM);
        sendBtn.setBackgroundColor(Color.TRANSPARENT);

        mInputRow.addView(prompt);
        mInputRow.addView(mInputView);
        mInputRow.addView(sendBtn);

        mRoot.addView(titleRow);
        mRoot.addView(mChoiceBar);
        mRoot.addView(mTerminalContainer);
        mRoot.addView(mInputRow);
        setContentView(mRoot);

        btnA.setOnClickListener(v -> launchSession(CMD_A_LABEL, CMD_A));
        btnB.setOnClickListener(v -> launchSession(CMD_B_LABEL, CMD_B));
        btnC.setOnClickListener(v -> launchSession(CMD_C_LABEL, CMD_C));

        Runnable sendAction = () -> {
            if (mSession == null) return;
            String cmd = mInputView.getText().toString();
            if (!cmd.isEmpty()) {
                mSession.write(cmd + "\n");
                mInputView.setText("");
            }
        };
        sendBtn.setOnClickListener(v -> sendAction.run());
        mInputView.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_SEND ||
                    (event != null && event.getKeyCode() == KeyEvent.KEYCODE_ENTER
                            && event.getAction() == KeyEvent.ACTION_DOWN)) {
                sendAction.run();
                return true;
            }
            return false;
        });
    }

    private Button makeChoiceButton(String label, int textColor) {
        Button btn = new Button(this);
        btn.setText(label);
        btn.setTypeface(Typeface.MONOSPACE);
        btn.setTextSize(10f);
        btn.setTextColor(textColor);
        btn.setBackgroundColor(0xFF21262D);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMargins(8, 0, 8, 0);
        btn.setLayoutParams(lp);
        return btn;
    }

    private void launchSession(String label, String initialCommand) {
        // Reuse the existing shell if one is already running, instead of
        // spawning a second process and stacking a second EmulatorView.
        if (mSession != null) {
            mSession.write(initialCommand + "\n");
            mChoiceBar.setVisibility(View.GONE);
            return;
        }

        mChoiceBar.setVisibility(View.GONE);

        try {
            mProcess = Runtime.getRuntime().exec(new String[]{
                    "/system/bin/sh",
                    "-i"
            });

            mSession = new TermSession();
            // Wrap the raw pipe so bare \n becomes \r\n, same as a real pty
            // would do — this is what fixes the staircase/cascade output.
            mSession.setTermIn(new CrLfFilterInputStream(mProcess.getInputStream()));
            mSession.setTermOut(mProcess.getOutputStream());

            DisplayMetrics metrics = getResources().getDisplayMetrics();

            mEmulatorView = new EmulatorView(this, mSession, metrics);
            mEmulatorView.setLayoutParams(new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT));

            mEmulatorView.setColorScheme(new ColorScheme(0xFFC9D1D9, COLOR_BG));
            mEmulatorView.setTextSize(12);
            mEmulatorView.setDensity(metrics);
            mEmulatorView.setFocusable(true);
            mEmulatorView.setFocusableInTouchMode(true);

            mTerminalContainer.addView(mEmulatorView);
            mEmulatorView.requestFocus();

            mEmulatorView.post(() -> {
                mEmulatorView.updateSize(true);
                mInputView.setEnabled(true);

                if (mSession != null) {
                    String boot =
                            "PATH=/data/data/com.unisoc.su/files:$PATH" + "\n" +
                            "export PATH" + "\n" +
                            "cd /data/data/com.unisoc.su/files\n" +
                            "echo READY\n" +
                            initialCommand + "\n";
                    mSession.write(boot);
                }
            });

        } catch (IOException e) {
            Toast.makeText(this,
                    "Error starting shell: " + e.getMessage(),
                    Toast.LENGTH_LONG).show();
        }
    }

    /**
     * /system/bin/sh is run via a plain pipe, not a real pty, so the kernel
     * never expands a lone \n into \r\n the way a real terminal would.
     * Without that expansion, EmulatorView moves down a row but never
     * resets the column, so every line picks up where the last one ended —
     * the staircase/cascade effect. This stream patches that in software.
     */
    private static class CrLfFilterInputStream extends InputStream {
        private final InputStream mSource;
        private final byte[] mReadBuf = new byte[4096];
        private byte[] mPending = new byte[8192];
        private int mPendingLen = 0;
        private int mPendingPos = 0;
        private int mLastByte = -1;

        CrLfFilterInputStream(InputStream source) {
            mSource = source;
        }

        @Override
        public int read() throws IOException {
            byte[] one = new byte[1];
            int n = read(one, 0, 1);
            return n <= 0 ? -1 : (one[0] & 0xFF);
        }

        @Override
        public int read(byte[] buffer, int offset, int length) throws IOException {
            if (length <= 0) return 0;

            if (mPendingPos < mPendingLen) {
                int avail = mPendingLen - mPendingPos;
                int toCopy = Math.min(avail, length);
                System.arraycopy(mPending, mPendingPos, buffer, offset, toCopy);
                mPendingPos += toCopy;
                return toCopy;
            }

            int n = mSource.read(mReadBuf, 0, Math.min(mReadBuf.length, length));
            if (n <= 0) return n;

            byte[] translated = new byte[n * 2];
            int outLen = 0;
            for (int i = 0; i < n; i++) {
                byte b = mReadBuf[i];
                if (b == '\n' && mLastByte != '\r') {
                    translated[outLen++] = '\r';
                }
                translated[outLen++] = b;
                mLastByte = b;
            }

            int toCopy = Math.min(outLen, length);
            System.arraycopy(translated, 0, buffer, offset, toCopy);

            if (toCopy < outLen) {
                int remaining = outLen - toCopy;
                if (mPending.length < remaining) mPending = new byte[remaining];
                System.arraycopy(translated, toCopy, mPending, 0, remaining);
                mPendingLen = remaining;
                mPendingPos = 0;
            }

            return toCopy;
        }

        @Override
        public int available() throws IOException {
            return (mPendingLen - mPendingPos) + mSource.available();
        }

        @Override
        public void close() throws IOException {
            mSource.close();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mEmulatorView != null) mEmulatorView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mEmulatorView != null) mEmulatorView.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mSession != null) mSession.finish();
        if (mProcess != null) mProcess.destroy();
    }
}
