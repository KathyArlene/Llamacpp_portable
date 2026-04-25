using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace TinyLMLauncherApp {
    internal static class Program {
        [STAThread]
        private static void Main() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new LauncherForm());
        }
    }

    public class LauncherForm : Form {
        private readonly TextBox _portBox = new TextBox();
        private readonly TextBox _ctxBox = new TextBox();
        private readonly TextBox _nglBox = new TextBox();
        private readonly Label _status = new Label();
        private Process _proc;

        private string RootPath {
            get {
                string exeDir = AppDomain.CurrentDomain.BaseDirectory;
                return Path.GetFullPath(Path.Combine(exeDir, "..", ".."));
            }
        }

        private string LlamaExe {
            get { return Path.Combine(RootPath, "tools", "llama", "llama-server.exe"); }
        }

        private string ModelsPreset {
            get { return Path.Combine(RootPath, "models", "models.ini"); }
        }

        public LauncherForm() {
            Text = "TinyLM llama.cpp 启动器";
            Width = 560;
            Height = 280;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;

            var title = new Label { Left = 20, Top = 15, Width = 500, Text = "llama.cpp WebUI 启动器", Font = new System.Drawing.Font("Segoe UI", 11, System.Drawing.FontStyle.Bold) };
            Controls.Add(title);

            Controls.Add(new Label { Left = 20, Top = 55, Width = 120, Text = "端口:" });
            _portBox.Left = 140; _portBox.Top = 52; _portBox.Width = 120; _portBox.Text = "8080";
            Controls.Add(_portBox);

            Controls.Add(new Label { Left = 20, Top = 85, Width = 120, Text = "上下文:" });
            _ctxBox.Left = 140; _ctxBox.Top = 82; _ctxBox.Width = 120; _ctxBox.Text = "32768";
            Controls.Add(_ctxBox);

            Controls.Add(new Label { Left = 20, Top = 115, Width = 120, Text = "GPU层数:" });
            _nglBox.Left = 140; _nglBox.Top = 112; _nglBox.Width = 120; _nglBox.Text = "99";
            Controls.Add(_nglBox);

            Controls.Add(new Label { Left = 20, Top = 145, Width = 120, Text = "模型预设:" });
            Controls.Add(new Label { Left = 140, Top = 145, Width = 380, Text = @"models\models.ini" });

            var startBtn = new Button { Left = 140, Top = 180, Width = 100, Text = "启动" };
            var stopBtn = new Button { Left = 260, Top = 180, Width = 100, Text = "停止" };
            startBtn.Click += delegate { StartServer(); };
            stopBtn.Click += delegate { StopServer(); };
            Controls.Add(startBtn);
            Controls.Add(stopBtn);

            _status.Left = 20; _status.Top = 220; _status.Width = 500; _status.Text = "就绪";
            Controls.Add(_status);
        }

        private void StartServer() {
            if (_proc != null && !_proc.HasExited) {
                _status.Text = "llama.cpp 已在运行。";
                return;
            }

            int port;
            if (!int.TryParse(_portBox.Text.Trim(), out port) || port <= 0 || port > 65535) {
                MessageBox.Show("端口必须是 1-65535 的数字。");
                return;
            }
            int ctx;
            if (!int.TryParse(_ctxBox.Text.Trim(), out ctx) || ctx <= 0) {
                MessageBox.Show("上下文必须是正整数。");
                return;
            }
            int ngl;
            if (!int.TryParse(_nglBox.Text.Trim(), out ngl) || ngl < 0) {
                MessageBox.Show("GPU层数必须是 >= 0 的整数。");
                return;
            }
            if (!File.Exists(LlamaExe)) {
                MessageBox.Show("未找到 llama-server.exe:\n" + LlamaExe);
                return;
            }
            if (!File.Exists(ModelsPreset)) {
                MessageBox.Show("未找到 models.ini:\n" + ModelsPreset);
                return;
            }

            var psi = new ProcessStartInfo {
                FileName = LlamaExe,
                WorkingDirectory = RootPath,
                Arguments = string.Format("-c {0} -ngl {1} --models-preset \"{2}\" --webui --host 127.0.0.1 --port {3}", ctx, ngl, ModelsPreset, port),
                UseShellExecute = false
            };

            _proc = Process.Start(psi);
            _status.Text = string.Format("已启动，PID={0}，端口={1}", _proc.Id, port);
            Process.Start(new ProcessStartInfo(string.Format("http://127.0.0.1:{0}/", port)) { UseShellExecute = true });
        }

        private void StopServer() {
            if (_proc == null || _proc.HasExited) {
                _status.Text = "当前没有运行中的 llama.cpp。";
                return;
            }
            _proc.Kill();
            _status.Text = "已停止 llama.cpp。";
        }
    }
}
