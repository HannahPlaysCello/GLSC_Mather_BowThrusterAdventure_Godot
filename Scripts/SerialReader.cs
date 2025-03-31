using Godot;
using System;
using System.IO.Ports;

public partial class SerialReader : Node
{
	[Signal]
	public delegate void DataReceivedEventHandler(string data);

	private SerialPort serialPort;
	[Export] public string PortName = "COM5";
	[Export] public int BaudRate = 9600;
	[Export] public float ReconnectInterval = 3.0f;

	//private Label outputLabel;
	private float reconnectTimer = 0.0f;

	public override void _Ready()
	{
		//outputLabel = GetNode<Label>("Label");
		TryConnect();
	}

	public override void _Process(double delta)
	{
		if (serialPort != null && serialPort.IsOpen)
		{
			try
			{
				while (serialPort.BytesToRead > 0)
				{
					string data = serialPort.ReadLine()?.Trim();
					if (!string.IsNullOrEmpty(data))
					{
						GD.Print(data);
						EmitSignal(nameof(DataReceived), data);
					}
				}
			}
			catch (Exception ex)
			{
				GD.PrintErr("Read error: " + ex.Message);
				ClosePort(); // Close it safely without spamming reconnection
			}
		}
		else
		{
			// Try to reconnect
			reconnectTimer += (float)delta;
			if (reconnectTimer >= ReconnectInterval)
			{
				TryConnect();
				reconnectTimer = 0.0f; // Reset timer after each attempt
			}
		}
	}

	private void TryConnect()
	{
		try
		{
			if (serialPort != null && serialPort.IsOpen)
			{
				GD.Print("Already connected to " + PortName);
				return;
			}
			serialPort = new SerialPort(PortName, BaudRate);
			serialPort.Open();
			GD.Print("Connected to " + PortName);
			//outputLabel.Text = "Connected to " + PortName;
		}
		catch (Exception ex)
		{
			GD.PrintErr("Failed to connect: " + ex.Message);
			//outputLabel.Text = "Failed to connect. Retrying in " + ReconnectInterval + " seconds...";
		}
	}

	private void ClosePort()
	{
		try
		{
			if (serialPort != null && serialPort.IsOpen)
			{
				serialPort.Close();
				GD.Print("Serial connection closed.");
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr("Error while closing port: " + ex.Message);
		}
		finally
		{
			serialPort = null; // Reset so it doesn't try to reuse a bad port
		}
	}

	public override void _ExitTree()
	{
		ClosePort();
	}
}
