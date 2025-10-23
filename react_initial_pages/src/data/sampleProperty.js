const baseImage = (path) => `${process.env.PUBLIC_URL || ''}${path}`;

export const SAMPLE_PROPERTY = {
  id: 'sample-property',
  title: 'Modern 3BR Apartment in Downtown',
  description:
    'Beautiful modern apartment with stunning city views. Features include hardwood floors, stainless steel appliances, and floor-to-ceiling windows.',
  propertyType: 'buy',
  price: 450000,
  bedrooms: 3,
  bathrooms: 2,
  sizeSqft: 1500,
  furnished: true,
  addressLine: '123 Main Street',
  city: 'New York',
  state: 'NY',
  country: 'USA',
  postalCode: '10001',
  tags: ['Modern', 'Downtown', 'Parking', 'Gym'],
  rooms: [
    {
      id: 'room-living',
      name: 'Living Room',
      order: 0,
      defaultViewpointId: 'vp-living-center',
      viewpoints: [
        {
          id: 'vp-living-center',
          name: 'Center',
          panoramaDataUrl: baseImage('/test_360_images/living-room.jpg'),
          isDefault: true,
          hotspots: [
            {
              id: 'hs-living-kitchen',
              targetViewpointId: 'vp-kitchen-center',
              yaw: -0.6,
              pitch: 0,
              label: 'Kitchen',
            },
            {
              id: 'hs-living-bedroom',
              targetViewpointId: 'vp-bedroom-center',
              yaw: 1.2,
              pitch: 0,
              label: 'Bedroom',
            },
          ],
        },
      ],
    },
    {
      id: 'room-kitchen',
      name: 'Kitchen',
      order: 1,
      defaultViewpointId: 'vp-kitchen-center',
      viewpoints: [
        {
          id: 'vp-kitchen-center',
          name: 'Center',
          panoramaDataUrl: baseImage('/test_360_images/kitchen.jpg'),
          isDefault: true,
          hotspots: [
            {
              id: 'hs-kitchen-living',
              targetViewpointId: 'vp-living-center',
              yaw: 2.8,
              pitch: 0,
              label: 'Back to Living Room',
            },
          ],
        },
      ],
    },
    {
      id: 'room-bedroom',
      name: 'Master Bedroom',
      order: 2,
      defaultViewpointId: 'vp-bedroom-center',
      viewpoints: [
        {
          id: 'vp-bedroom-center',
          name: 'Center',
          panoramaDataUrl: baseImage('/test_360_images/bedroom.jpg'),
          isDefault: true,
          hotspots: [
            {
              id: 'hs-bedroom-living',
              targetViewpointId: 'vp-living-center',
              yaw: -2.4,
              pitch: 0,
              label: 'Living Room',
            },
          ],
        },
      ],
    },
  ],
};

export const extractCoverImage = (property) => {
  const firstRoom = property.rooms?.[0];
  const firstViewpoint =
    firstRoom?.viewpoints?.find((vp) => vp.id === firstRoom?.defaultViewpointId) ||
    firstRoom?.viewpoints?.[0];
  return (
    firstViewpoint?.panoramaDataUrl ||
    firstViewpoint?.preview_image_url ||
    baseImage('/test_360_images/living-room.jpg')
  );
};
