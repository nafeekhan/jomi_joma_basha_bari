/**
 * Room Model
 * Represents a physical room with multiple viewpoints
 */

class Room {
  constructor(data = {}) {
    this.id = data.id || null;
    this.name = data.name || data.room_name || '';
    this.order = data.order || data.room_order || 0;
    this.defaultViewpointId = data.defaultViewpointId || data.default_viewpoint_id || null;
    this.viewpoints = data.viewpoints || [];
  }

  // Add a viewpoint to this room
  addViewpoint(viewpoint) {
    this.viewpoints.push(viewpoint);
  }

  // Remove a viewpoint
  removeViewpoint(viewpointId) {
    this.viewpoints = this.viewpoints.filter(v => v.id !== viewpointId);
  }

  // Get the default viewpoint
  getDefaultViewpoint() {
    if (this.defaultViewpointId) {
      return this.viewpoints.find(v => v.id === this.defaultViewpointId);
    }
    return this.viewpoints.find(v => v.isDefault) || this.viewpoints[0];
  }

  // Check if this room has multiple viewpoints
  hasMultipleViewpoints() {
    return this.viewpoints.length > 1;
  }

  // Convert to API format
  toJSON() {
    return {
      id: this.id,
      room_name: this.name,
      room_order: this.order,
      default_viewpoint_id: this.defaultViewpointId,
      viewpoints: this.viewpoints
    };
  }
}

export default Room;

