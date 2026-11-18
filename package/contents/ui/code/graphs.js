.pragma library
// @ts-check
/**
 * @import {GraphTypes, Graph, GraphDefaultsMap, DisplayInfoTemplate, DisplayInfo} from "./graphs.d.ts"
 */

/**
 * Version of graphs
 * @constant
 */
const VERSION = 4; //? Graph entries with another version are ignored by parse()

/**
 * Note: Field "_v", "type", "sizes", "fontSize" is filled by {@link #create} function
 * @type {GraphDefaultsMap}
 * @constant
 */
const GRAPH_DEFAULTS = {
  // CPU
  cpu: {
    colors: ["highlightColor", "textColor", "textColor"],
    sensorsType: ["usage", "classic", false],
    thresholds: [85, 105],
    clockAggregator: "average",
    eCoresCount: 0,
  },
  cpuText: {
    colors: ["textColor", "highlightColor"],
    sensorsType: ["usage"],
    title: "CPU",
    titleWhen: "always",
  },

  // Memory
  memory: {
    colors: ["highlightColor", "negativeTextColor", "highlightColor"],
    sensorsType: ["application", "swap", true],
    thresholds: [70, 90],
  },
  memoryText: {
    colors: ["textColor", "highlightColor"],
    sensorsType: ["physical-percent"],
    title: "RAM",
    titleWhen: "always",
  },

  // GPU
  gpu: {
    colors: ["highlightColor", "positiveTextColor", "textColor"],
    sensorsType: ["usage", "memory", false],
    thresholds: [80, 90],
  },
  gpuText: {
    colors: ["textColor", "highlightColor"],
    sensorsType: ["usage"],
    title: "GPU",
    titleWhen: "always",
  },

  // Network
  network: {
    colors: ["highlightColor", "positiveTextColor"],
    sensorsType: [false, "kibibyte"],
    uplimits: [100000, 100000],
    ignoredInterfaces: [],
    icons: false,
  },
  networkText: {
    colors: ["highlightColor", "positiveTextColor"],
    sensorsType: [false, "kibibyte"],
    ignoredInterfaces: [],
    icons: true,
  },

  // Disk
  disk: {
    colors: ["highlightColor", "positiveTextColor"],
    sensorsType: [false],
    uplimits: [200000, 200000],
    icons: false,
  },
  diskText: {
    colors: ["textColor", "highlightColor"],
    sensorsType: ["used-percent"],
    icons: false,
    title: "Disk",
    titleWhen: "always",
  },

  // Battery
  batteryText: {
    colors: ["textColor", "highlightColor"],
    sensorsType: ["percentage", true],
    thresholds: [15, 5],
    title: "Battery",
    titleWhen: "always",
  },

  // Text
  text: {
    color: "textColor",
    device: "Text",
    placement: "middle-right",
    fontSize: 10, // WARN: This is fallback value,  default came from argument of {@link  #create} function
  },
};

/**
 * The list of graph types need an device
 * @type {Set<GraphTypes>}
 * @constant
 */
const DEVICE_REQUIRED_TYPES = new Set([
  "gpu",
  "gpuText",
  "disk",
  "diskText",
  "batteryText",
]);

/**
 * @type {Record<GraphTypes, DisplayInfoTemplate>}
 * @constant
 */
const GRAPH_DISPLAY = {
  cpu: {
    name: ["Chart name", "CPU"],
    icon: "cpu-symbolic",
    fallbackIcon: "cpu",
  },
  cpuText: {
    name: ["Chart name", "CPU (text)"],
    icon: "cpu-symbolic",
    fallbackIcon: "cpu",
  },
  memory: {
    name: ["Chart name", "Memory"],
    icon: "memory-symbolic",
    fallbackIcon: "memory",
  },
  memoryText: {
    name: ["Chart name", "Memory (text)"],
    icon: "memory-symbolic",
    fallbackIcon: "memory",
  },
  gpu: {
    name: ["Chart name", "GPU [%1]"],
    icon: "freon-gpu-temperature-symbolic",
    fallbackIcon: "preferences-desktop-display",
    withDeviceName: true,
  },
  gpuText: {
    name: ["Chart name", "GPU (text) [%1]"],
    icon: "freon-gpu-temperature-symbolic",
    fallbackIcon: "preferences-desktop-display",
    withDeviceName: true,
  },
  network: {
    name: ["Chart name", "Network"],
    icon: "network-wired-symbolic",
    fallbackIcon: "network-wired",
  },
  networkText: {
    name: ["Chart name", "Network (text)"],
    icon: "network-wired-symbolic",
    fallbackIcon: "network-wired",
  },
  disk: {
    name: ["Chart name", "Disk I/O [%1]"],
    icon: "drive-harddisk-symbolic",
    fallbackIcon: "drive-harddisk",
    withDeviceName: true,
  },
  diskText: {
    name: ["Chart name", "Disk (text) [%1]"],
    icon: "drive-harddisk-symbolic",
    fallbackIcon: "drive-harddisk",
    withDeviceName: true,
  },
  batteryText: {
    name: ["Chart name", "Battery (text) [%1]"],
    icon: "battery-symbolic",
    fallbackIcon: "battery",
    withDeviceName: true,
  },
  text: {
    name: ["Chart name", "Text"],
    icon: "dialog-text-and-font",
    fallbackIcon: "draw-text",
  },
};

/**
 * Parse json string to graph array. Entries from another graph version are skipped.
 * @param {string} raw The raw graphs value (in json string)
 * @returns {Graph[]} The parsed graphs
 */
function parse(raw) {
  /** @type {Graph[]} */
  const graphs = JSON.parse(raw || "[]");
  return graphs.filter((graph) => graph._v === VERSION);
}

/**
 * Stringify the graphs array
 * @param {Graph[]} graphs The graphs array
 * @returns {string} The stringified array
 */
function stringify(graphs) {
  return JSON.stringify(graphs);
}

/**
 * Create new graph with given type and device
 * @param {GraphTypes} type The graph type
 * @param {string} [device] The device
 * @param {number} [fontSize] The default font size
 * @returns {Graph} The created graph
 */
function create(type, device, fontSize) {
  const defaults = GRAPH_DEFAULTS[type];
  if (!defaults) throw new Error(`${type} is not valid graph type`);

  const item = Object.assign(
    {
      _v: VERSION,
      type,
      sizes: [-1, -1],
      fontSize: -1,
    },
    _cloneDefaults(defaults),
  );

  if (DEVICE_REQUIRED_TYPES.has(type)) {
    if (!device?.trim())
      throw new Error(`Device is required for ${type} graph`);
    /** @type {any} */ (item).device = device;
  }

  // Default text font size
  if (type === "text")
    item.fontSize =
      fontSize ?? /** @type {{fontSize: number}} */ (defaults).fontSize;

  return /** @type {Graph} */ (item);
}
/**
 * Shallow-clone an object, cloning array properties one level deep
 * @template {object} T
 * @param {T} obj The object to clone
 * @returns {T} The cloned object
 */
function _cloneDefaults(obj) {
  const out = /** @type {T} */ ({});
  for (const key in obj) {
    out[key] = Array.isArray(obj[key])
      ? /** @type {any} */ ([...obj[key]])
      : obj[key];
  }
  return out;
}

/**
 * Retrieve graph display informations (name and icon)
 * @param {Graph["type"]} type The graph type
 * @param {(context: string, source: string, arg?: string) => string} i18nc The "i18nc" function //? bypass QML limitation
 * @param {string} [section] The section name
 * @param {string} [device] The device identifier
 * @param {string} [deviceName] The device name
 * @returns {GraphInfo} The display informations
 */
function getDisplayInfo(
  type,
  i18nc = (_context, source) => source,
  section = "",
  device = type,
  deviceName = device,
) {
  const template = GRAPH_DISPLAY[type];
  if (!template) throw new Error(`${type} is not valid graph type`);

  const [context, source] = template.name;

  return {
    type,
    section,
    device,
    name: template.withDeviceName
      ? i18nc(context, source, deviceName)
      : i18nc(context, source),
    icon: template.icon,
    fallbackIcon: template.fallbackIcon,
  };
}
