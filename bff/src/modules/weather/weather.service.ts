export interface DayWeatherForecast {
  date: string; // YYYY-MM-DD
  maxTemp: string;
  minTemp: string;
  condition: string;
  icon: string;
  precipitationProbability: number;
  uvIndex?: number;
}

export interface CurrentWeather {
  temp: string;
  apparentTemp: string;
  humidity: string;
  windSpeed: string;
  condition: string;
  icon: string;
  isDay: boolean;
  waterTemp?: string;
}

export interface WeatherData {
  city: string;
  state?: string;
  current: CurrentWeather;
  daily: DayWeatherForecast[];
  lastUpdated: string;
}

// Weather code mapping according to WMO Weather interpretation codes
export function mapWmoCodeToCondition(code: number): { condition: string; icon: string } {
  switch (code) {
    case 0:
      return { condition: 'Céu limpo', icon: '☀️' };
    case 1:
      return { condition: 'Predominantemente limpo', icon: '🌤️' };
    case 2:
      return { condition: 'Parcialmente nublado', icon: '⛅' };
    case 3:
      return { condition: 'Nublado', icon: '☁️' };
    case 45:
    case 48:
      return { condition: 'Nevoeiro', icon: '🌫️' };
    case 51:
    case 53:
    case 55:
      return { condition: 'Garoa leve', icon: '🌦️' };
    case 56:
    case 57:
      return { condition: 'Garoa congelante', icon: '🌧️' };
    case 61:
      return { condition: 'Chuva fraca', icon: '🌦️' };
    case 63:
      return { condition: 'Chuva moderada', icon: '🌧️' };
    case 65:
      return { condition: 'Chuva forte', icon: '🌧️' };
    case 66:
    case 67:
      return { condition: 'Chuva congelante', icon: '🌧️' };
    case 71:
    case 73:
    case 75:
      return { condition: 'Neve', icon: '❄️' };
    case 80:
      return { condition: 'Pancadas de chuva leve', icon: '🌦️' };
    case 81:
      return { condition: 'Pancadas de chuva', icon: '🌧️' };
    case 82:
      return { condition: 'Pancadas de chuva torrencial', icon: '⛈️' };
    case 95:
      return { condition: 'Tempestade com trovoadas', icon: '⛈️' };
    case 96:
    case 99:
      return { condition: 'Tempestade com granizo', icon: '⛈️' };
    default:
      return { condition: 'Tempo bom', icon: '☀️' };
  }
}

// In-memory cache with 30 min TTL
const weatherCache = new Map<string, { timestamp: number; data: WeatherData }>();
const CACHE_TTL_MS = 30 * 60 * 1000;

export class WeatherService {
  /**
   * Search coordinates for a city using Open-Meteo Geocoding API
   */
  static async getCoordinates(city: string, state?: string): Promise<{ lat: number; lon: number; name: string } | null> {
    try {
      const cleanCity = city.trim();
      const searchQuery = state ? `${cleanCity} ${state}` : cleanCity;
      const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(searchQuery)}&count=1&language=pt&format=json`;

      const response = await fetch(url, { headers: { 'User-Agent': 'FamiliaPartiuApp/1.0' } });
      if (!response.ok) {
        // Fallback without state
        const fallbackUrl = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cleanCity)}&count=1&language=pt&format=json`;
        const fbRes = await fetch(fallbackUrl);
        if (!fbRes.ok) return null;
        const fbJson: any = await fbRes.json();
        if (fbJson.results && fbJson.results.length > 0) {
          const r = fbJson.results[0];
          return { lat: r.latitude, lon: r.longitude, name: r.name };
        }
        return null;
      }

      const json: any = await response.json();
      if (json.results && json.results.length > 0) {
        const r = json.results[0];
        return { lat: r.latitude, lon: r.longitude, name: r.name };
      }

      // Default fallback for Maceió
      if (cleanCity.toLowerCase().includes('macei')) {
        return { lat: -9.6658, lon: -35.7353, name: 'Maceió' };
      }

      return null;
    } catch (e) {
      console.warn('Geocoding fetch error:', (e as Error).message);
      if (city.toLowerCase().includes('macei')) {
        return { lat: -9.6658, lon: -35.7353, name: 'Maceió' };
      }
      return null;
    }
  }

  /**
   * Get real-time weather and 14-day daily forecast for a destination
   */
  static async getWeatherForDestination(city: string, state?: string): Promise<WeatherData> {
    const cacheKey = `${city.toLowerCase()}_${(state || '').toLowerCase()}`;
    const cached = weatherCache.get(cacheKey);

    if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
      return cached.data;
    }

    // Default fallback data (in case API fails or offline)
    const fallbackData: WeatherData = {
      city,
      state: state || 'Brasil',
      current: {
        temp: '29°C',
        apparentTemp: '31°C',
        humidity: '72%',
        windSpeed: '18 km/h',
        condition: 'Ensolarado com brisa do mar',
        icon: '☀️',
        isDay: true,
        waterTemp: '27°C'
      },
      daily: Array.from({ length: 14 }).map((_, i) => {
        const d = new Date();
        d.setDate(d.getDate() + i);
        const iso = d.toISOString().split('T')[0];
        return {
          date: iso,
          maxTemp: '30°C',
          minTemp: '24°C',
          condition: 'Ensolarado',
          icon: '☀️',
          precipitationProbability: 10,
          uvIndex: 9
        };
      }),
      lastUpdated: new Date().toISOString()
    };

    try {
      const coords = await this.getCoordinates(city, state);
      if (!coords) {
        return fallbackData;
      }

      const forecastUrl = `https://api.open-meteo.com/v1/forecast?latitude=${coords.lat}&longitude=${coords.lon}&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max&timezone=auto&forecast_days=14`;

      const response = await fetch(forecastUrl, { headers: { 'User-Agent': 'FamiliaPartiuApp/1.0' } });
      if (!response.ok) {
        return fallbackData;
      }

      const json: any = await response.json();
      const currentRaw = json.current;
      const dailyRaw = json.daily;

      const currentMapped = mapWmoCodeToCondition(currentRaw.weather_code);
      const currentTemp = Math.round(currentRaw.temperature_2m);
      const apparentTemp = Math.round(currentRaw.apparent_temperature);
      const humidity = Math.round(currentRaw.relative_humidity_2m);
      const windSpeed = Math.round(currentRaw.wind_speed_10m);

      const dailyList: DayWeatherForecast[] = [];
      if (dailyRaw && dailyRaw.time) {
        for (let i = 0; i < dailyRaw.time.length; i++) {
          const dateStr = dailyRaw.time[i];
          const wCode = dailyRaw.weather_code[i];
          const mapped = mapWmoCodeToCondition(wCode);
          const max = Math.round(dailyRaw.temperature_2m_max[i]);
          const min = Math.round(dailyRaw.temperature_2m_min[i]);
          const pop = Math.round(dailyRaw.precipitation_probability_max ? dailyRaw.precipitation_probability_max[i] : 0);
          const uv = dailyRaw.uv_index_max ? Math.round(dailyRaw.uv_index_max[i]) : undefined;

          dailyList.push({
            date: dateStr,
            maxTemp: `${max}°C`,
            minTemp: `${min}°C`,
            condition: mapped.condition,
            icon: mapped.icon,
            precipitationProbability: pop,
            uvIndex: uv
          });
        }
      }

      const result: WeatherData = {
        city: coords.name || city,
        state: state || '',
        current: {
          temp: `${currentTemp}°C`,
          apparentTemp: `${apparentTemp}°C`,
          humidity: `${humidity}%`,
          windSpeed: `${windSpeed} km/h`,
          condition: currentMapped.condition,
          icon: currentMapped.icon,
          isDay: currentRaw.is_day === 1,
          waterTemp: '27°C'
        },
        daily: dailyList.length > 0 ? dailyList : fallbackData.daily,
        lastUpdated: new Date().toISOString()
      };

      weatherCache.set(cacheKey, { timestamp: Date.now(), data: result });
      return result;
    } catch (e) {
      console.warn('Open-Meteo forecast fetch error:', (e as Error).message);
      return fallbackData;
    }
  }
}
