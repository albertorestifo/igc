defmodule IGC.Position do
  @doc """
  A position on earth as a latitude and longitude in the WGS84 system
  """
  defstruct [:lat, :lng]

  @type t :: %__MODULE__{
          lat: float,
          lng: float
        }

  @spec parse(String.t()) :: {:ok, t(), String.t()} | {:error, atom}
  def parse(line) do
    with {:ok, lat, rest} <- read_coords(line, :lat),
         {:ok, lng, rest} <- read_coords(rest, :lng) do
      {:ok, %__MODULE__{lat: lat, lng: lng}, rest}
    end
  end

  @spec read_coords(String.t(), :lat | :lng) :: {:ok, float, String.t()} | {:error, atom}
  defp read_coords(line, :lat) do
    with {:ok, lat, rest} <- read_degrees(line, 2),
         {:ok, pole, rest} <- IGC.Parser.take(rest, 1) do
      case pole do
        "N" -> {:ok, lat, rest}
        "S" -> {:ok, -lat, rest}
      end
    end
  end

  defp read_coords(line, :lng) do
    with {:ok, lng, rest} <- read_degrees(line, 3),
         {:ok, pole, rest} <- IGC.Parser.take(rest, 1) do
      case pole do
        "E" -> {:ok, lng, rest}
        "W" -> {:ok, -lng, rest}
      end
    end
  end

  @spec read_degrees(String.t(), non_neg_integer()) :: {:ok, float, String.t()} | {:error, atom}
  defp read_degrees(line, size) do
    with {:ok, deg, rest} <- IGC.Parser.take(line, size, :int),
         {:ok, min, rest} <- IGC.Parser.take(rest, 5, :int),
         minutes <- min / 1000 / 60 do
      {:ok, Float.round(deg + minutes, 6), rest}
    end
  end
end
