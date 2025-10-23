export const STORAGE_KEY = 'jjbb_property_draft';

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

export const createProperty = ({
  id = 'demo-property',
  title = '',
  description = '',
  propertyType = 'buy',
  price = '',
  bedrooms = '',
  bathrooms = '',
  sizeSqft = '',
  furnished = false,
  addressLine = '',
  city = '',
  state = '',
  country = '',
  postalCode = '',
  tags = [],
  rooms = [],
}) => ({
  id,
  title,
  description,
  propertyType,
  price,
  bedrooms,
  bathrooms,
  sizeSqft,
  furnished,
  addressLine,
  city,
  state,
  country,
  postalCode,
  tags,
  rooms,
});

export const savePropertyToStorage = (property) => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(property));
  } catch (error) {
    console.error('Failed to save property to storage', error);
  }
};

export const loadPropertyFromStorage = () => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    return parsed;
  } catch (error) {
    console.error('Failed to load property from storage', error);
    return null;
  }
};

export const clearPropertyStorage = () => {
  localStorage.removeItem(STORAGE_KEY);
};

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
