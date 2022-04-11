using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TrailRenderer))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed = 200.0f;
    [SerializeField] private float boostFactor = 4.0f;
    [SerializeField] private float power = 2.0f;
    [SerializeField] private TerrainGenerator generatedTerrain;

    private float trailDecay = 5.0f;
    private float modifiedSpeed;
    private Vector3 movementDirection; 
    private TrailRenderer trail;

    void Awake()
    {
        this.transform.position = new Vector3(this.generatedTerrain.width/2, this.generatedTerrain.height/2, this.transform.position.z);
        this.trail = this.GetComponent<TrailRenderer>();
        if(this.generatedTerrain == null)
        {
            Debug.Log("You need pass a TrarrainGenerator component to the player.");
            throw new MissingComponentException();
        }
    }

    public float GetCurrentSpeed()
    {
        return this.modifiedSpeed;
    }

    public Vector3 GetMovementDirection()
    {
        return this.movementDirection;
    }

    void Update()
    {
        if(Input.GetButton("Fire1"))
        {
            this.generatedTerrain.ChangeTerrainHeight(this.gameObject.transform.position, this.power);
        }
        if(Input.GetButton("Fire2"))
        {
            this.generatedTerrain.ChangeTerrainHeight(this.gameObject.transform.position, -this.power);
        }

        this.modifiedSpeed = this.speed;
        if (Input.GetButton("Jump")) 
        {
            this.modifiedSpeed *= this.boostFactor;
            this.trail.widthMultiplier = this.boostFactor;
        }
        else
        {
            if(this.trail.widthMultiplier >= 1.0f) {
                this.trail.widthMultiplier -= Time.deltaTime * this.trailDecay;
            }
        }
        this.movementDirection = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0.0f);
        this.gameObject.transform.Translate(this.movementDirection * Time.deltaTime * this.modifiedSpeed);
    }
}
