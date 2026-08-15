import { setMarkerAlphaLocal } from "@paulbarmstrong/js-to-sqf"

export async function showMarkers(markers: Array<string>) {
	markers.forEach(marker => setMarkerAlphaLocal(marker, 1))
}

export async function hideMarkers(markers: Array<string>) {
	markers.forEach(marker => setMarkerAlphaLocal(marker, 0))
}
