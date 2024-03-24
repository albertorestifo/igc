defmodule IGCParserTest do
  use ExUnit.Case, async: true
  use Mneme

  doctest IGC.Headers

  test "Parses example file #1" do
    data =
      File.stream!("test/fixtures/sample_1.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 4835

    [head | _tail] = data

    auto_assert {:fix,
                 %IGC.Fix{
                   compensated_variometer: 1.8,
                   extensions: %{
                     "ACZ" => "4-0",
                     "FXA" => "012",
                     "SIU" => "31",
                     "VAT" => "0180",
                     "VXA" => "140"
                   },
                   gnss_altitude: 1231,
                   horizontal_accuracy: 12,
                   position: %IGC.Position{lat: 40.254933, lng: -4.906333},
                   pressure_altitude: 1267,
                   satellite_in_use: 31,
                   time: ~T[12:34:32],
                   valid?: true,
                   vertical_accuracy: 140
                 },
                 %IGC.Headers{
                   competition_class: :unknown,
                   competition_id: :unknown,
                   date: ~D[2022-12-03],
                   firmware_version: "1.0",
                   fix_extensions: %IGC.Extensions{
                     extensions: [
                       {"FXA", 36, 38},
                       {"SIU", 39, 40},
                       {"VAT", 41, 44},
                       {"ACZ", 45, 47},
                       {"VXA", 48, 50}
                     ]
                   },
                   flight_number: 0,
                   flight_recorder_id: "XSE1520211297",
                   flight_recorder_type: "Syride,SYS'Nav XL",
                   glider_id: :unknown,
                   glider_type: "BGD Epic",
                   gnss_altitude: "GEO",
                   pilot: "Alberto Restifo",
                   pressure_altitude: "ISA",
                   pressure_sensor: "TE,MS5607,30480",
                   raw_headers: %{
                     "ALG" => {"ALTGPS", "GEO"},
                     "ALP" => {"ALTPRESSURE", "ISA"},
                     "CCL" => {"COMPETITIONCLASS", "NKN"},
                     "CID" => {"COMPETITIONID", "NKN"},
                     "CM2" => {"CREW2", "NIL"},
                     "DTE" => {"DATE", "031222,00"},
                     "DTM" => {"GPSDATUM", "WGS84"},
                     "FTY" => {"FRTYPE", "Syride,SYS'Nav XL"},
                     "GID" => {"GLIDERID", "NKN"},
                     "GPS" => {"RECEIVER", "UBlox,MAX-M8Q,72ch,10000m"},
                     "GTY" => {"GLIDERTYPE", "BGD Epic"},
                     "PLT" => {"PILOTINCHARGE", "Alberto Restifo"},
                     "PRS" => {"PRESSALTSENSOR", "TE,MS5607,30480"},
                     "RFW" => {"HARDWAREVERSION", "1.0"}
                   }
                 }} <- head
  end

  test "Parses example file #2" do
    data =
      File.stream!("test/fixtures/sample_2.igc")
      |> IGC.Parser.parse()
      |> Enum.to_list()

    assert length(data) == 661

    [head | _tail] = data

    auto_assert {:fix,
                 %IGC.Fix{
                   extensions: %{"FXA" => "012", "SIU" => "52"},
                   gnss_altitude: 1252,
                   horizontal_accuracy: 12,
                   position: %IGC.Position{lat: 40.44765, lng: -4.5065},
                   pressure_altitude: 1103,
                   satellite_in_use: 52,
                   time: ~T[14:19:38],
                   valid?: true
                 },
                 %IGC.Headers{
                   competition_id: :unknown,
                   date: ~D[2023-02-05],
                   firmware_version: "2022-12-22:a2e86365",
                   fix_extensions: %IGC.Extensions{extensions: [{"FXA", 36, 38}, {"SIU", 39, 40}]},
                   flight_recorder_id: "XSDUB4799",
                   flight_recorder_type: "STODEUS,ULTRABIP",
                   glider_id: :unknown,
                   glider_type: "BGD Base 2",
                   gnss_altitude: "GEO",
                   hardware_version: "ULTRABIP 1.0",
                   pilot: "Alberto Restifo",
                   pressure_altitude: "ISA",
                   pressure_sensor: "INFINEON,DPS310,7000",
                   raw_headers: %{
                     "ALG" => {"ALTGPS", "GEO"},
                     "ALP" => {"ALTPRESSURE", "ISA"},
                     "CID" => {"COMPETITIONID", "NKN"},
                     "CM2" => {"CREW2", "NIL"},
                     "DTE" => {nil, "050223"},
                     "DTM" => {"GPSDATUM", "WGS84"},
                     "FTY" => {"FRTYPE", "STODEUS,ULTRABIP"},
                     "GID" => {"GLIDERID", "NKN"},
                     "GPS" => {"RECEIVER", "GOTOP,GT1110SN,22,18000"},
                     "GTY" => {"GLIDERTYPE", "BGD Base 2"},
                     "PLT" => {"PILOTINCHARGE", "Alberto Restifo"},
                     "PRS" => {"PRESSALTSENSOR", "INFINEON,DPS310,7000"},
                     "RFW" => {"FIRMWAREVERSION", "2022-12-22:a2e86365"},
                     "RHW" => {"HARDWAREVERSION", "ULTRABIP 1.0"},
                     "TZN" => {"TIMEZONE", "1"}
                   },
                   timezone: "1"
                 }} <- head
  end

  # test "Parsers the entire file without streaming" do
  #   res =
  #     File.read!("test/fixtures/sample_1.igc")
  #     |> IGC.Parser.parse_all()

  #   auto_assert res
  # end
end
