import { createFeatureSelector, createSelector } from '@ngrx/store';
import { IncidentState, adapter } from './incident.reducer';
import { IncidentStatus } from '../../core/models/incident.model';


export const selectIncidentState = createFeatureSelector<IncidentState>('incidents');

const { selectAll } = adapter.getSelectors();

// 3. Selektor za SVE incidente
export const selectAllIncidents = createSelector(
  selectIncidentState,
  selectAll
);

// 4. Selektor za samo AKTIVNE incidente (oni koji nisu RESOLVED)
export const selectActiveIncidents = createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.status !== IncidentStatus.RESOLVED)
);

// 5. Selektor za statistiku
export const selectIncidentStatistics = createSelector(
  selectAllIncidents,
  (incidents) => {
    return {
      total: incidents.length,
      active: incidents.filter(i => i.status !== IncidentStatus.RESOLVED).length,
      critical: incidents.filter(i => i.severity === 'CRITICAL' && i.status !== IncidentStatus.RESOLVED).length,
      unassigned: incidents.filter(i => !i.assignedTo && i.status !== IncidentStatus.RESOLVED).length
    };
  }
);

// 6. Selektor za loading indikator
export const selectIncidentsLoading = createSelector(
  selectIncidentState,
  (state) => state.loading
);

// 7. Selektor za gresku
export const selectIncidentsError = createSelector(
  selectIncidentState,
  (state) => state.error
);


export const selectIncidentsBySensorId = (sensorId: number) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.id === sensorId && i.status !== IncidentStatus.RESOLVED)
);



export const selectMyIncidents = (user: any) => createSelector(
  selectAllIncidents,
  (incidents) => {
    if (!user) return [];
    const myUsername = user.username.toLowerCase();
    const myId = user.id;

    return incidents.filter(i => {

      if (!i.assignedTo) {
        // Proveri da li se pominje u opisu
        return i.description?.toLowerCase().includes(myUsername);
      }

      // 1. Provera da li je dodeljen meni (preko ID-a ili username-a)
      const isAssigned =
        i.assignedTo?.id === myId ||
        i.assignedTo?.username?.toLowerCase() === myUsername ||
        (typeof i.assignedTo === 'string' && i.assignedTo === myUsername);
     
      return isAssigned;

    });

  }

);

export const selectFilteredIncidents = (criteria: { severity?: string, creator?: string, sensorId?: number }) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => {
    const matchSeverity = criteria.severity ? i.severity === criteria.severity : true;
    const matchCreator = criteria.creator ? i.description.toLowerCase().includes(criteria.creator.toLowerCase()) : true;
    const matchSensor = criteria.sensorId ? i.id === criteria.sensorId : true;
    return matchSeverity && matchCreator && matchSensor;
  })
);

export const selectSensorIncidentHistory = (sensorId: number) => createSelector(
  selectAllIncidents,
  (incidents) => incidents.filter(i => i.sensor?.id === sensorId)
);

export const selectUserAnalytics = (user: any) => createSelector(
  selectAllIncidents,
  (allIncidents) => {
    if (!user) return null;
    const myUsername = user.username.toLowerCase();
    const myId = user.id;

    // 1. Incidenti koji su TRENUTNO kod njega u radu
    const activeIncidents = allIncidents.filter(i => i.assignedTo?.id === myId && i.status === IncidentStatus.IN_PROGRESS);
    const openOrInProgressCount = activeIncidents.length;

    // 2. Incidenti koje je uspesno RESOLVED sa njegovim ID-jem
    const resolvedIncidents = allIncidents.filter(i => i.assignedTo?.id === myId && i.status === IncidentStatus.RESOLVED);
    const resolvedCount = resolvedIncidents.length;

    // 3. BROJANJE ODUSTAJANJA: Gledamo kroz logove svih incidenata da li ima zapis o odustajanju ovog korisnika
    const abandonedCount = allIncidents.filter(i => 
      i.historyLogs && i.historyLogs.toLowerCase().includes(`@${myUsername} odustao`)
    ).length;

    // 4. UKUPAN UCINAK: Sve što je rešio + ono što mu je trenutno aktivno + ono od čega je odustao!
    const totalAssigned = resolvedCount + openOrInProgressCount + abandonedCount;

    // 5. PROCENAT USPEHA: Uspesno reseni u odnosu na sve sto je dotakao (reseno + odustao)
    // Ako ima reseno 1 i odustao 1, procenat je 50% (1 / 2)
    const totalDeliveredAndAbandoned = resolvedCount + abandonedCount;
    const resolutionPercentage = totalDeliveredAndAbandoned > 0 
      ? Math.round((resolvedCount / totalDeliveredAndAbandoned) * 100) 
      : 0;

    // --- Kalkulacija vremena rada  ---
    let avgResolutionTimeMin = 0;
    let medianResolutionTimeMin = 0;
    let longestResolutionTimeMin = 0;
    
    const resolutionDurations = resolvedIncidents
      .filter(i => i.pickedUpAt && i.resolvedAt) 
      .map(i => {
        const start = new Date(i.pickedUpAt!).getTime();
        const end = new Date(i.resolvedAt!).getTime();
        return (end - start) / (1000 * 60);
      });

    if (resolutionDurations.length > 0) {
      const sum = resolutionDurations.reduce((acc, val) => acc + val, 0);
      avgResolutionTimeMin = Math.round(sum / resolutionDurations.length);
      longestResolutionTimeMin = Math.round(Math.max(...resolutionDurations));

      const sortedDurations = [...resolutionDurations].sort((a, b) => a - b);
      const mid = Math.floor(sortedDurations.length / 2);
      medianResolutionTimeMin = sortedDurations.length % 2 !== 0 
        ? Math.round(sortedDurations[mid]) 
        : Math.round((sortedDurations[mid - 1] + sortedDurations[mid]) / 2);
    }

    const severityStats = {
      LOW: resolvedIncidents.filter(i => i.severity === 'LOW').length,
      MEDIUM: resolvedIncidents.filter(i => i.severity === 'MEDIUM').length,
      HIGH: resolvedIncidents.filter(i => i.severity === 'HIGH').length,
      CRITICAL: resolvedIncidents.filter(i => i.severity === 'CRITICAL').length,
    };

    return {
      totalAssigned,
      resolvedCount,
      openOrInProgressCount,
      abandonedCount, 
      resolutionPercentage,
      avgResolutionTimeMin,
      medianResolutionTimeMin,
      longestResolutionTimeMin,
      severityStats
    };
  }
);

export const selectUsersLeaderboard = (period: string) => createSelector(
  selectAllIncidents,
  (incidents) => {
    const now = new Date();

    //1.FILTRIRANJE INCIDENATA NA OSNOVU PERIODA
    const filteredIncidents = incidents.filter(i => {
      // Ako incident nije rešen, preskačemo ga odmah
      if (i.status !== IncidentStatus.RESOLVED || !i.resolvedAt) return false;

      const resolvedDate = new Date(i.resolvedAt);
      const diffInMs = now.getTime() - resolvedDate.getTime();
      const diffInDays = diffInMs / (1000 * 60 * 60 * 24);

      if (period === '24h') return diffInMs <= 1000 * 60 * 60 * 24; // Unutar poslednja 24 sata
      if (period === '7d') return diffInDays <= 7;                  // Unutar poslednjih 7 dana
      if (period === '30d') return diffInDays <= 30;                // Unutar poslednjih 30 dana
      return true; // Ako je 'all', propusti sve rešene incidente
    });

    // 2. Mapa korisnika koji imaju resene incidente u ovom periodu
    const userMap = new Map<number, any>();
    
    incidents.forEach(i => {
      if (i.assignedTo) {
        userMap.set(i.assignedTo.id, i.assignedTo);
      }
    });

    // 3. Obracunavanje statistike
    return Array.from(userMap.values()).map(user => {
      const stats = selectUserAnalytics(user).projector(filteredIncidents);

      return {
      id: user.id,
      username: user.username,
      name: user.fullName || user.username,
      resolvedCount: stats ? stats.resolvedCount : 0,
      avgResolutionTimeMin: stats ? stats.avgResolutionTimeMin : 0,
      successPercentage: stats ? stats.resolutionPercentage : 0
      };
    })

    .filter(u => u.resolvedCount > 0)
    .sort((a, b) => {
      if (b.resolvedCount !== a.resolvedCount) {
        return b.resolvedCount - a.resolvedCount;
      }
      return a.avgResolutionTimeMin - b.avgResolutionTimeMin;
    });
  }
);

