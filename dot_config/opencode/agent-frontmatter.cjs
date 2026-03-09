"use strict";

const DEFAULT_REQUIRED_FIELDS = ["name", "description", "model"];

module.exports = {
  names: ["agent-frontmatter-fields"],
  description: "Require common YAML frontmatter fields in agent docs",
  tags: ["front_matter", "yaml", "opencode"],
  function: (params, onError) => {
    if (params.config === false || params.config?.enabled === false) {
      return;
    }

    const fileName = params.name || "";
    if (!/(^|[\\/])agent[\\/].+\.md$/i.test(fileName)) {
      return;
    }

    const frontMatterLines = params.frontMatterLines || [];
    if (frontMatterLines.length === 0) {
      onError({
        lineNumber: 1,
        detail: "Missing YAML frontmatter block (expected leading '---').",
      });
      return;
    }

    const presentFields = new Set();
    for (const line of frontMatterLines) {
      const match = /^([A-Za-z_][A-Za-z0-9_-]*)\s*:/.exec(line);
      if (match) {
        presentFields.add(match[1]);
      }
    }

    const requiredFields = Array.isArray(params.config?.required_fields)
      ? params.config.required_fields
      : DEFAULT_REQUIRED_FIELDS;

    const missingFields = requiredFields.filter((field) => !presentFields.has(field));
    if (missingFields.length > 0) {
      onError({
        lineNumber: 1,
        detail: `Missing required frontmatter fields: ${missingFields.join(", ")}.`,
      });
    }
  },
};
