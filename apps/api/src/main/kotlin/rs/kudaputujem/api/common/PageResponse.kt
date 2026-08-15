package rs.kudaputujem.api.common

/** Isti oblik paginacije na svim endpointima. */
data class PageResponse<T>(
    val data: List<T>,
    val total: Long,
    val page: Int,
    val pageSize: Int,
) {
    val totalPages: Int get() = if (pageSize <= 0) 0 else ((total + pageSize - 1) / pageSize).toInt()
    val hasNext: Boolean get() = page < totalPages

    companion object {
        fun <T> of(data: List<T>, total: Long, page: Int, pageSize: Int) =
            PageResponse(data, total, page, pageSize)

        fun <T> empty(page: Int, pageSize: Int) =
            PageResponse<T>(emptyList(), 0, page, pageSize)
    }
}
