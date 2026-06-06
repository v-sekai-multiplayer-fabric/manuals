-- Surface a decision's tier and status (from YAML frontmatter) at the top of the
-- rendered page. This keeps the frontmatter the single source of truth: the
-- decisions index shows tier/status as columns, and this shows them on each page,
-- so authors never repeat them in the body.

function Pandoc(doc)
  local meta = doc.meta
  if meta.status == nil and meta.tier == nil then
    return doc
  end

  local ins = {}
  local function add_field(label, value)
    if #ins > 0 then
      ins[#ins + 1] = pandoc.Space()
      ins[#ins + 1] = pandoc.Str("·")
      ins[#ins + 1] = pandoc.Space()
    end
    ins[#ins + 1] = pandoc.Strong({ pandoc.Str(label .. ":") })
    ins[#ins + 1] = pandoc.Space()
    ins[#ins + 1] = pandoc.Str(pandoc.utils.stringify(value))
  end

  if meta.tier ~= nil then add_field("Tier", meta.tier) end
  if meta.status ~= nil then add_field("Status", meta.status) end

  table.insert(doc.blocks, 1, pandoc.Para(ins))
  return doc
end
