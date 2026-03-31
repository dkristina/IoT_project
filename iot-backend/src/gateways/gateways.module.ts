import { Module } from '@nestjs/common';
import { IotGateway } from './iot.gateway';

@Module({
  providers: [IotGateway],
  exports: [IotGateway],
})

export class GatewaysModule {}