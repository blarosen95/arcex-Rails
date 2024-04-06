CURRENCIES = YAML.load_file(Rails.root.join('config', 'truths', 'currencies.yml'))["currencies"].map(&:with_indifferent_access)
