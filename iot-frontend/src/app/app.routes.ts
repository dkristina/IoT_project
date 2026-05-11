import { Routes } from "@angular/router";
import { DashboardComponent } from "./pages/dashboard/dashboard";
import { LoginComponent } from "./auth/login/login";
import { SensorsComponent } from "./pages/sensor/sensor";
import { SensorDetailsComponent } from "./components/sensor-details/sensor-details";
import { EditSensorComponent } from "./components/edit-sensor/edit-sensor";
import { AddSensorComponent } from "./components/add-sensor/add-sensor";
import { AlarmsListComponent } from "./components/alarm-list/alarm-list";
import { IncidentListComponent } from "./components/incident-list/incident-list";
import { ProfileComponent } from "./components/profil/profil";
import { AuthGuard } from "./core/guards/auth.guard";
import { UsersComponent } from "./components/users/users";

export const routes: Routes = [
  { path: 'dashboard', component: DashboardComponent },
  { path: 'login', component: LoginComponent },

  // DEFAULT
  { path: '', redirectTo: 'login', pathMatch: 'full' },

  
  { path: 'sensors', component: SensorsComponent, canActivate: [AuthGuard] },
  { path: 'sensors/new', component: AddSensorComponent, canActivate: [AuthGuard] },
  { path: 'sensors/:id', component: SensorDetailsComponent, canActivate: [AuthGuard] },
  { path: 'sensors/edit/:id', component: EditSensorComponent, canActivate: [AuthGuard] },
  { path: 'alarms', component: AlarmsListComponent, canActivate: [AuthGuard] },
  { path: 'incidents', component: IncidentListComponent, canActivate: [AuthGuard] },
  { path: 'profile', component: ProfileComponent, canActivate: [AuthGuard] },
  { path: 'users', component: UsersComponent, canActivate: [AuthGuard] },
];