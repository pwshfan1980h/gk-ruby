BeforeAll do
  DatabaseCleaner.clean_with(
    :truncation,
    except: %w[ar_internal_metadata schema_migrations]
  )
end
