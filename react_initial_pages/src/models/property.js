const generateId = () => {
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  return `id-${Date.now()}-${Math.random().toString(16).slice(2, 10)}`;
};

export const createHotspot = ({ id = Date.now().toString(), yaw = 0, pitch = 0, targetViewpointId }) => ({
  id,
  yaw,
  pitch,
  targetViewpointId,
});

export const createViewpoint = ({
  id,
  name,
  panoramaDataUrl = null,
  isDefault = false,
  hotspots = [],
}) => ({
  id: id || generateId(),
  name,
  panoramaDataUrl,
  isDefault,
  hotspots,
});

export const createRoom = ({ id, name, order = 0, viewpoints = [], defaultViewpointId = null }) => ({
  id: id || generateId(),
  name,
  order,
  defaultViewpointId,
  viewpoints,
});

export const findViewpointById = (rooms, viewpointId) => {
  for (const room of rooms || []) {
    const match = room.viewpoints?.find((vp) => vp.id === viewpointId);
    if (match) {
      return { room, viewpoint: match };
    }
  }
  return null;
};

export const normaliseRooms = (rooms = []) =>
  rooms
    .map((room, index) => ({
      ...room,
      order: room.order ?? index,
      viewpoints: (room.viewpoints || []).map((vp, vpIndex) => ({
        ...vp,
        hotspots: vp.hotspots || [],
        name: vp.name || `Viewpoint ${vpIndex + 1}`,
        id: vp.id || generateId(),
      })),
      id: room.id || crypto.randomUUID(),
    }))
    .sort((a, b) => a.order - b.order);
