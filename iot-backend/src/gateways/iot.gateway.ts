import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

// @WebSocketGateway dekorator otvara "vrata" na portu bekenda
@WebSocketGateway({
  cors: {
    origin: '*', // Dozvoljavamo frontendu da se poveze 
  },
})
export class IotGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger: Logger = new Logger('IotGateway');

  //saljemo merenje na kanal "newMeasurement"
  sendMeasurementUpdate(measurement: any) {
    this.server.emit('newMeasurement', measurement);
  }

  //saljemo incident na kanal "newIncident"
  sendIncidentAlert(incident: any) {
    this.server.emit('newIncident', incident);
  }


  handleConnection(client: Socket) {
    this.logger.log(`Client connected to WebSocket: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`The client has disconnected: ${client.id}`);
  }
}