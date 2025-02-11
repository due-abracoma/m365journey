# Load the required assembly
Add-Type -AssemblyName System.Windows.Forms

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sample GUI"
$form.Size = New-Object System.Drawing.Size(300, 300)

# Create radio buttons
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Text = "Option 1"
$radioButton1.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($radioButton1)

$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Text = "Option 2"
$radioButton2.Location = New-Object System.Drawing.Point(10, 40)
$form.Controls.Add($radioButton2)

# Create dropdown (combobox)
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(10, 70)
$comboBox.Size = New-Object System.Drawing.Size(200, 20)
$comboBox.Items.AddRange(@("Item 1", "Item 2", "Item 3"))
$form.Controls.Add($comboBox)

# Create button to open file dialog
$fileButton = New-Object System.Windows.Forms.Button
$fileButton.Text = "Select File"
$fileButton.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($fileButton)

# Create label to display selected file path
$fileLabel = New-Object System.Windows.Forms.Label
$fileLabel.Location = New-Object System.Drawing.Point(10, 130)
$fileLabel.Size = New-Object System.Drawing.Size(260, 20)
$form.Controls.Add($fileLabel)

# Add event handler for file button click
$fileButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $fileLabel.Text = $fileDialog.FileName
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()