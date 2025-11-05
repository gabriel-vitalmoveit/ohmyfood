import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import fetch from 'node-fetch';

@Injectable()
export class MapboxService {
  constructor(private readonly configService: ConfigService) {}

  async geocode(address: string) {
    const accessToken = this.configService.get<string>('mapbox.apiKey');
    if (!accessToken) {
      throw new Error('MAPBOX_API_KEY não configurada');
    }
    const encoded = encodeURIComponent(address);
    const response = await fetch(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${encoded}.json?access_token=${accessToken}`,
    );
    return response.json();
  }
}
