import { Incident } from './incident.model';

export enum UserRole {
  ADMIN = 'ADMIN',
  OPERATOR = 'OPERATOR'
}

export interface User {
  id: number;
  username: string;
  email: string;
  fullName?: string;
  avatarUrl: string;
  role: UserRole;
  incidents?: Incident[];
}