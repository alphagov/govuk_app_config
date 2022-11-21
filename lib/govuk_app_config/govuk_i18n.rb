module GovukI18n
  def self.plurals
    {
      # Azerbaijani
      az: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Welsh
      cy: { i18n: { plural: { keys: %i[zero one two few many other],
                              rule:
                                lambda do |n|
                                  case n
                                  when 0 then :zero
                                  when 1 then :one
                                  when 2 then :two
                                  when 3 then :few
                                  when 6 then :many
                                  else :other
                                  end
                                end } } },
      # Dari - this isn't an iso code. Probably should be 'prs' as per ISO 639-3.
      dr: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Latin America and Caribbean Spanish
      "es-419": { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Persian
      fa: { i18n: { plural: { keys: %i[one other], rule: ->(n) { [0, 1].include?(n) ? :one : :other } } } },
      # Scottish Gaelic
      gd: { i18n: { plural: { keys: %i[one two few other],
                              rule:
                                lambda do |n|
                                  if [1, 11].include?(n)
                                    :one
                                  elsif [2, 12].include?(n)
                                    :two
                                  elsif [3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15, 16, 17, 18, 19].include?(n)
                                    :few
                                  else
                                    :other
                                  end
                                end } } },
      # Armenian
      hy: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Georgian
      ka: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Kazakh
      kk: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Punjabi Shahmukhi
      "pa-pk": { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Maltese
      mt: { i18n: { plural: { keys: %i[one few many other],
                              rule:
                                lambda do |n|
                                  n ||= 0
                                  mod100 = n % 100

                                  if n == 1
                                    :one
                                  elsif n.zero? || (2..10).to_a.include?(mod100)
                                    :few
                                  elsif (11..19).to_a.include?(mod100)
                                    :many
                                  else
                                    :other
                                  end
                                end } } },
      # Sinhalese
      si: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Turkish
      tr: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Uzbek
      uz: { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Chinese
      zh: { i18n: { plural: { keys: %i[other], rule: ->(_) { :other } } } },
      # Chinese Hong Kong
      "zh-hk" => { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
      # Chinese Taiwan
      "zh-tw" => { i18n: { plural: { keys: %i[one other], rule: ->(n) { n == 1 ? :one : :other } } } },
    }
  end
end
