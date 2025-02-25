class CommentTag < LiquidTagBase
  PARTIAL = "comments/liquid".freeze
  REGISTRY_REGEXP = %r{#{URL.url}/\w+/comment/(?<comment_id>\w+)}
  VALID_ID_REGEXP = /\A(?<comment_id>\w+)\Z/
  REGEXP_OPTIONS = [REGISTRY_REGEXP, VALID_ID_REGEXP].freeze

  def initialize(_tag_name, id_code, _parse_context)
    super

    input    = CGI.unescape_html(strip_tags(id_code))
    @comment = find_comment(parse_id_code(input))
  end

  def render(_context)
    ApplicationController.render(
      partial: PARTIAL,
      locals: { comment: @comment },
    )
  end

  def find_comment(id_code)
    Comment.find_by(id_code: id_code)
  end

  private

  def parse_id_code(input)
    match = pattern_match_for(input, REGEXP_OPTIONS)
    raise StandardError, "Invalid Comment ID or URL" unless match

    match[:comment_id]
  end
end

Liquid::Template.register_tag("comment", CommentTag)
# kept for compatibility with existing comments embeds on DEV
Liquid::Template.register_tag("devcomment", CommentTag)

UnifiedEmbed.register(CommentTag, regexp: CommentTag::REGISTRY_REGEXP)
