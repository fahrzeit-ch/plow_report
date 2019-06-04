json.partial! 'api/v1/shared/pagination', pagination_source: @records
json.items @records, partial: 'site', as: :site