class Parser

  attr_reader :text, :highlight_hashes

  def initialize(text:, highlight_hashes:)
    @text = text
    @highlight_hashes = highlight_hashes
  end


  def call
    construct_html
  end


  private

  def clean_text_array
    text.split("\n\n").map(&:strip)
  end

  def sanitized_string
    text.split("\n\n").map(&:strip).join(' \n\n ')
  end

  def words_array
    sanitized_string.gsub(' \\n\\n ', ' ').split
  end

  def line_break_index
    sanitized_string.split.each_with_index.map { |item, index| index if item == '\\n\\n' }.compact
  end

  def sort_highlight_hashes
    highlight_hashes.sort_by { |hsh| hsh[:start] }
  end

  def apply_highlight_tags
    words = words_array
    sort_highlight_hashes.each do |highlight|
      starter = highlight[:start]
      ender = highlight[:end] - 1
      words[starter] = '<mark>' + words[starter]
      words[ender] = words[ender] + '</mark>'
    end
    words
  end

  def apply_line_breaks
    with_highlights = apply_highlight_tags
    line_break_index.each do |ln|
      with_highlights.insert(ln, '/n/n')
    end
    with_highlights
  end

  def construct_html
    lines = apply_line_breaks.join.split(line_break)
    lines.map { |line| "<p>#{line}</p>" }.join
  end

  def line_break
    '/n/n'
  end

  # def apply_paragraph_tags
  #   binding.pry
  #   text = line_break_index.map  { |ln|  with_highlights.insert(index, '</p><p>') }
  #   "<p>#{text}</p>"
  # end

end
