using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class TerrainGenerator : MonoBehaviour
{
    public int XVertices = 250;
    public int YVertices = 250;
    public float Width = 10000.0f;
    public float Height = 10000.0f;
    public float NoiseScale = 0.001f;
    public float Amplitude = 75.0f;
    public float Frequency = 100.0f;
    public float MinHeight = -10000.0f;
    public float MaxHeight = 10000.0f;
    public bool NormalizeHeight = true;
    private Vector3[] Vertices;
    private Mesh Mesh;

    void Awake()
    { 
        this.Vertices = new Vector3[(this.XVertices + 1) * (this.YVertices + 1)];
        this.Generate();
    }

    public void Generate()
    {
        this.Mesh = new Mesh();
        this.gameObject.GetComponent<MeshFilter>().mesh = this.Mesh;
        this.Mesh.name = "PCG Terrain";

        this.Vertices = new Vector3[(this.XVertices + 1) * (this.YVertices + 1)];
        var uv = new Vector2[this.Vertices.Length];

        var noiseMap = this.PerlinNoiseMap(this.NoiseScale);

        for (int i = 0, y = 0; y <= this.YVertices; y++)
        {
            for (int x = 0; x <= this.XVertices; x++, i++)
            {
                var vpos = new Vector3(
                    (float)x * this.Width / (float)this.XVertices, 
                    (float)y * this.Height / (float)this.YVertices, 
                    (float)noiseMap[i]);
                this.Vertices[i] = vpos;
                uv[i] = new Vector2((float)x / (float)this.XVertices, (float)y / (float)this.YVertices);
            }
        }

        this.Mesh.vertices = this.Vertices;
        this.Mesh.uv = uv;

        int[] triangles = new int[this.XVertices * this.YVertices * 6];
        for (int ti = 0, vi = 0, y = 0; y < this.YVertices; y++, vi++)
        {
            for (int x = 0; x < this.XVertices; x++, ti += 6, vi++)
            {
                triangles[ti] = vi;
                triangles[ti + 3] = triangles[ti + 2] = vi + 1;
                triangles[ti + 4] = triangles[ti + 1] = vi + this.XVertices + 1;
                triangles[ti + 5] = vi + this.XVertices + 2;
            }
        }
        this.Mesh.triangles = triangles;
        this.Mesh.RecalculateNormals();
    }

    private float[] PerlinNoiseMap(float scale = 0.001f)
    { 
        var noiseMap = new float[(this.XVertices + 1) * (this.YVertices + 1)];
        var min = float.MaxValue;
        var max = float.MinValue;

        for (int y = 0, i = 0; y <= this.YVertices; y++)
        {
            for (var x = 0; x <= this.XVertices; x++, i++)
            {
                float value = Mathf.PerlinNoise((float)x * scale * this.Frequency, (float)y * scale * this.Frequency);
                noiseMap[i] = Mathf.Clamp(value, this.MinHeight, this.MaxHeight);
                if(value < min)
                {
                    min = value;
                }
                if(value > max)
                {
                    max = value;
                }
            }
        }

        for (var i = 0; i < noiseMap.Length; ++i)
        {
            if (this.NormalizeHeight)
            {
                noiseMap[i] = this.Amplitude * (noiseMap[i] - min) / (max - min);
            }
            else
            {
                noiseMap[i] = this.Amplitude * noiseMap[i];
            }
        }

        return noiseMap;
    }

    public void ChangeTerrainHeight(Vector3 worldPosition, float amount)
    {
        //determine the vertex number
        var localPosition = this.transform.InverseTransformPoint(worldPosition);
        float xv =  localPosition.x / ((float)this.Width / ((float)this.XVertices));
        float yv = localPosition.y / ((float)this.Height / ((float)this.YVertices));
        int vertexIndex = Mathf.RoundToInt(xv) + Mathf.RoundToInt(yv) * (this.XVertices+1);

        //flip the amount to match our flipped z-coords
        if(vertexIndex < this.Vertices.Length) { 
            this.Vertices[vertexIndex].z += -amount;
            this.Mesh.vertices = this.Vertices;
        }
    }
}
