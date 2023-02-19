defmodule IGCHeadersTest do
  use Snapshy
  use ExUnit.Case

  doctest IGC.Headers

  test_snapshot "Parses example headers #1" do
    example_headers = [
      "FDTE160223",
      "FPLTPILOTINCHARGE:Alberto Restifo",
      "FCM2CREW2:NIL",
      "FGTYGLIDERTYPE:BGD Base 2",
      "FGIDGLIDERID:NKN",
      "FCIDCOMPETITIONID:NKN",
      "FDTMGPSDATUM:WGS84",
      "FRFWFIRMWAREVERSION:2022-12-22:a2e86365",
      "FRHWHARDWAREVERSION:ULTRABIP 1.0",
      "FFTYFRTYPE:STODEUS,ULTRABIP",
      "FGPSRECEIVER:GOTOP,GT1110SN,22,18000",
      "FTZNTIMEZONE:1",
      "FPRSPRESSALTSENSOR:INFINEON,DPS310,7000",
      "FALGALTGPS:GEO",
      "FALPALTPRESSURE:ISA"
    ]

    Enum.reduce(example_headers, %IGC.Headers{}, fn line, headers ->
      assert {:ok, headers} = IGC.Headers.parse_line(line, headers)
      headers
    end)
  end

  test_snapshot "Parses example headers #2" do
    example_headers = [
      "FDTEDATE:031222,00",
      "FPLTPILOTINCHARGE:Alberto Restifo",
      "FCM2CREW2:NIL",
      "FGTYGLIDERTYPE:BGD Epic",
      "FGIDGLIDERID:NKN",
      "FDTMGPSDATUM:WGS84",
      "FRFWFIRMWAREVERSION:1.17",
      "FRFWHARDWAREVERSION:1.0",
      "FFTYFRTYPE:Syride,SYS'Nav XL",
      "FGPSRECEIVER:UBlox,MAX-M8Q,72ch,10000m",
      "FPRSPRESSALTSENSOR:TE,MS5607,30480",
      "FALGALTGPS:GEO",
      "FALPALTPRESSURE:ISA",
      "FCIDCOMPETITIONID:NKN",
      "FCCLCOMPETITIONCLASS:NKN"
    ]

    Enum.reduce(example_headers, %IGC.Headers{}, fn line, headers ->
      assert {:ok, headers} = IGC.Headers.parse_line(line, headers)
      headers
    end)
  end
end
