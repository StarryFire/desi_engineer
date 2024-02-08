package viewutil

import (
	"slices"
	"testing"
)

func Test_GetPaginationIndices_FullNavigation(t *testing.T) {
	got := GetPaginationIndices(1, 6, 5)
	want := []int{1, 2, 3, 4, 5}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(2, 6, 5)
	want = []int{1, 2, 3, 4, 5}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(3, 6, 5)
	want = []int{1, 2, 3, 4, 5}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(4, 6, 5)
	want = []int{2, 3, 4, 5, 6}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(5, 6, 5)
	want = []int{2, 3, 4, 5, 6}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(6, 6, 5)
	want = []int{2, 3, 4, 5, 6}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}
}

func Test_GetPaginationIndices_LessThanMaxIndices(t *testing.T) {
	got := GetPaginationIndices(1, 2, 5)
	want := []int{1, 2}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}

	got = GetPaginationIndices(2, 2, 5)
	want = []int{1, 2}
	if !slices.Equal(got, want) {
		t.Errorf("got %q, wanted %q", got, want)
	}
}
